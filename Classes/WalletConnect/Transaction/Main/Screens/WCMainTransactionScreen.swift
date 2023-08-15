// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   WCMainTransactionScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import MagpieHipo
import MacaroonBottomOverlay
import UIKit
import SnapKit

protocol WCMainTransactionScreenDelegate: AnyObject {
    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didSigned request: WalletConnectRequest,
        in session: WCSession?
    )
    func wcMainTransactionScreen(
         _ wcMainTransactionScreen: WCMainTransactionScreen,
         didRejected request: WalletConnectRequest
     )
}

final class WCMainTransactionScreen: BaseViewController, Container {
    weak var delegate: WCMainTransactionScreenDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var theme = Theme()

    private lazy var dappMessageView = WCTransactionDappMessageView()

    private lazy var singleTransactionFragment = WCSingleTransactionRequestScreen(
        dataSource: dataSource,
        configuration: configuration,
        currencyFormatter: currencyFormatter
    )

    private lazy var unsignedTransactionFragment = WCUnsignedRequestScreen(
        dataSource: dataSource,
        configuration: configuration
    )

    private var headerTransaction: WCTransaction?

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var wcTransactionSigner = WCTransactionSigner(
        api: api!,
        analytics: analytics
    )

    private lazy var transactionSignQueue = DispatchQueue.global(qos: .userInitiated)
    
    private var transactionParams: TransactionParams?
    private var signedTransactions: [Data?] = []

    private var isRejected = false

    private let wcSession: WCSession?

    private let transactions: [WCTransaction]
    private let transactionRequest: WalletConnectRequest
    private let transactionOption: WCTransactionOption?

    private let dataSource: WCMainTransactionDataSource

    private let currencyFormatter: CurrencyFormatter

    init(
        draft: WalletConnectRequestDraft,
        configuration: ViewControllerConfiguration
    ) {
        let currencyFormatter = CurrencyFormatter()
        self.transactions = draft.transactions
        self.transactionRequest = draft.request
        self.transactionOption = draft.option
        self.wcSession = configuration.walletConnector.getWalletConnectSession(for: transactionRequest.url.topic)
        self.dataSource = WCMainTransactionDataSource(
            sharedDataController: configuration.sharedDataController,
            transactions: transactions,
            transactionRequest: transactionRequest,
            transactionOption: transactionOption,
            walletConnector: configuration.walletConnector,
            currencyFormatter: currencyFormatter
        )
        self.currencyFormatter = currencyFormatter

        super.init(configuration: configuration)

        dataSource.delegate = self
        setTransactionSigners()
        setupObserver()
    }

    deinit {
        removeObserver()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    override func linkInteractors() {
        super.linkInteractors()

        singleTransactionFragment.delegate = self
        unsignedTransactionFragment.delegate = self
        wcTransactionSigner.delegate = self
        dappMessageView.delegate = self
    }

    override func viewDidLoad() {
        dataSource.load()

        super.viewDidLoad()
        
        logScreenWhenViewDidLoad()
        
        guard dataSource.hasValidGroupTransaction else {
            /// <note>: This check prevents to show multiple reject sheet
            /// When data source load function called, it will call delegate function to let us know if group transaction is not validated
            /// We could remove group validation in `validateTransactions` function but it also has another logic in it.s
            return
        }

        validateTransactions(transactions, with: dataSource.groupedTransactions)
        getAssetDetailsIfNeeded()
        getTransactionParams()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentInitialWarningAlertIfNeeded()
        logScreenWhenViewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        disconnectFromTheLedgerIfNeeeded()
    }
    
    override func bindData() {
        super.bindData()

        bindDappInfoView()
    }

    private func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeHeaderUpdate(notification:)),
            name: .SingleTransactionHeaderUpdate,
            object: nil
        )
    }

    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: .SingleTransactionHeaderUpdate,
            object: nil
        )
    }

    @objc
    private func observeHeaderUpdate(notification: Notification) {
        headerTransaction = notification.object as? WCTransaction

        bindDappInfoView()
    }

    private func bindDappInfoView() {
        guard let wcSession = walletConnector.allWalletConnectSessions.first(matching: (\.urlMeta.wcURL, transactionRequest.url)) else {
            return
        }

        let viewModel = WCTransactionDappMessageViewModel(
            session: wcSession,
            imageSize: CGSize(width: 48.0, height: 48.0),
            transactionOption: transactionOption,
            transaction: headerTransaction
        )
        dappMessageView.bind(viewModel)
    }
}

extension WCMainTransactionScreen {
    private func addUI() {
        addBackground()
        addDappInfoView()
        addSingleTransaction()
    }

    private func addBackground() {
        view.backgroundColor = theme.backgroundColor
    }

    private func addDappInfoView() {
        view.addSubview(dappMessageView)
        dappMessageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(theme.dappViewLeadingInset)
            make.top.safeEqualToTop(of: self).offset(theme.dappViewTopInset)
        }
    }

    private func addSingleTransaction() {
        let fragment = transactions.count > 1 ? unsignedTransactionFragment : singleTransactionFragment
        let container = NavigationContainer(rootViewController: fragment)
        addFragment(container) { fragmentView in
            fragmentView.roundCorners(corners: [.topLeft, .topRight], radius: theme.fragmentRadius)
            view.addSubview(fragmentView)
            fragmentView.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(theme.fragmentTopInset)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
}

// MARK: Signing Transactions
extension WCMainTransactionScreen: WCTransactionSignerDelegate {
    private func setTransactionSigners() {
        if let session = session {
            transactions.forEach { $0.findSignerAccount(in: sharedDataController.accountCollection, on: session) }
        }
    }

    private func confirmSigning() {
        loadingController?.startLoadingWithMessage("title-loading".localized)

        guard let transaction = getFirstSignableTransaction(),
              let index = transactions.firstIndex(of: transaction) else {
            loadingController?.stopLoading()
            rejectTransaction(with: .unauthorized(.signerNotFound))
            return
        }

        let requiresLedgerConnection = transaction.requestedSigner.account?.requiresLedgerConnection() ?? false
        if requiresLedgerConnection {
            openLedgerConnection()
        }

        transactionSignQueue.async {
            [weak self] in
            guard let self else { return }

            fillInitialUnsignedTransactions(until: index)
            signTransaction(transaction)
        }
    }

    private func getFirstSignableTransaction() -> WCTransaction? {
        return transactions.first { transaction in
            transaction.requestedSigner.account != nil
        }
    }

    private func fillInitialUnsignedTransactions(until index: Int) {
        for _ in 0..<index {
            signedTransactions.append(nil)
        }
    }

    private func signTransaction(_ transaction: WCTransaction) {
        if let signerAccount = transaction.requestedSigner.account {
            wcTransactionSigner.signTransaction(transaction, with: dataSource.transactionRequest, for: signerAccount)
        } else {
            signedTransactions.append(nil)
        }
    }

    func wcTransactionSigner(
        _ wcTransactionSigner: WCTransactionSigner,
        didSign transaction: WCTransaction,
        signedTransaction: Data
    ) {
        asyncMain {
            [weak self] in
            guard let self else { return}
            signWithLedgerProcessScreen?.increaseProgress()
        }

        signedTransactions.append(signedTransaction)

        transactionSignQueue.async {
            [weak self] in
            guard let self else { return }

            self.continueSigningTransactions(after: transaction)
        }
    }

    private func continueSigningTransactions(after transaction: WCTransaction) {
        if let index = transactions.firstIndex(of: transaction),
           let nextTransaction = transactions.nextElement(afterElementAt: index) {
            if let signerAccount = nextTransaction.requestedSigner.account {
                wcTransactionSigner.signTransaction(nextTransaction, with: transactionRequest, for: signerAccount)
            } else {
                signedTransactions.append(nil)
                continueSigningTransactions(after: nextTransaction)
            }
            return
        }

        dismissSignWithLedgerProcessScreen()

        if transactions.count != signedTransactions.count {
            asyncMain {
                [weak self] in
                guard let self else { return }

                loadingController?.stopLoading()

                rejectSigning(reason: .invalidInput(.unsignable))
            }
            return
        }

        sendSignedTransactions()
    }

    private func dismissSignWithLedgerProcessScreen() {
        asyncMain {
            [weak self] in
            guard let self else { return }

            signWithLedgerProcessScreen?.dismissScreen()
            signWithLedgerProcessScreen = nil
        }
    }

    private func sendSignedTransactions() {
        dataSource.signTransactionRequest(signature: signedTransactions)
        logAllTransactions()

        asyncMain {
            [weak self] in
            guard let self else { return }

            self.loadingController?.stopLoading()

            self.delegate?.wcMainTransactionScreen(self, didSigned: transactionRequest, in: wcSession)
        }
    }

    private func logAllTransactions() {
        transactions.forEach { transaction in
            if let transactionData = transaction.unparsedTransactionDetail,
               let session = wcSession {
                let transactionID = AlgorandSDK().getTransactionID(for: transactionData)
                analytics.track(
                    .wcTransactionConfirmed(
                        transactionID: transactionID,
                        dappName: session.peerMeta.name,
                        dappURL: session.peerMeta.url.absoluteString
                    )
                )
            }
        }
    }

    func wcTransactionSigner(
        _ wcTransactionSigner: WCTransactionSigner,
        didFailedWith error: WCTransactionSigner.WCSignError
    ) {
        asyncMain {
            [weak self] in
            guard let self else { return }
            loadingController?.stopLoading()

            switch error {
            case .api(let error):
                displaySigningError(error)

                rejectSigning(reason: .rejected(.unsignable))
            case .ledger(let error):
                displayLedgerError(error)
            case .missingUnparsedTransactionDetail:
                displayGenericError()
            }
        }
    }

    func wcTransactionSigner(
        _ wcTransactionSigner: WCTransactionSigner,
        didRequestUserApprovalFrom ledger: String
    ) {
        asyncMain {
            [weak self] in
            guard let self else { return }

            if signWithLedgerProcessScreen != nil { return }

            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

                self.openSignWithLedgerProcess(ledgerDeviceName: ledger)
            }
        }
    }

    func wcTransactionSignerDidFinishTimingOperation(_ wcTransactionSigner: WCTransactionSigner) { }

    func wcTransactionSignerDidResetLedgerOperation(_ wcTransactionSigner: WCTransactionSigner) {
        asyncMain {
            [weak self] in
            guard let self else { return }
            ledgerConnectionScreen?.dismissScreen()
            ledgerConnectionScreen = nil

            signWithLedgerProcessScreen?.dismissScreen()
            signWithLedgerProcessScreen = nil
        }
    }

    func wcTransactionSignerDidResetLedgerOperationOnSuccess(_ wcTransactionSigner: WCTransactionSigner) { }

    func wcTransactionSignerDidRejectedLedgerOperation(_ wcTransactionSigner: WCTransactionSigner) { }

    private func confirmTransaction() {
        let containsFutureTransaction = transactions.contains {
            guard let params = transactionParams else {
                return false
            }

            return $0.isFutureTransaction(with: params)
        }

        if containsFutureTransaction {
            presentSigningFutureTransactionAlert()
            return
        }

        confirmSigning()
    }

    private func presentSigningFutureTransactionAlert() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "wallet-connect-transaction-request-signing-future-transaction-alert-title".localized,
            description: .plain("wallet-connect-transaction-request-signing-future-transaction-alert-description".localized),
            primaryActionButtonTitle: "title-accept".localized,
            secondaryActionButtonTitle: "title-cancel".localized,
            primaryAction: { [weak self] in
                self?.confirmSigning()
            }
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }

    private func presentInitialWarningAlertIfNeeded() {
        let oneTimeDisplayStorage = OneTimeDisplayStorage()

        if oneTimeDisplayStorage.isDisplayedOnce(for: .wcInitialWarning) {
            return
        }

        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-green-large".uiImage,
            title: "wallet-connect-transaction-warning-initial-title".localized,
            description: .plain("wallet-connect-transaction-warning-initial-description".localized),
            secondaryActionButtonTitle: "title-close".localized
        )

        modalTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
        oneTimeDisplayStorage.setDisplayedOnce(for: .wcInitialWarning)
    }
    
    private func logScreenWhenViewDidLoad() {
        analytics.record(
            .wcTransactionRequestDidLoad(transactionRequest: transactionRequest)
        )
        
        analytics.track(
            .wcTransactionRequestDidLoad(transactionRequest: transactionRequest)
        )
    }
    
    private func logScreenWhenViewDidAppear() {
        if !isViewFirstAppeared {
            return
        }
        
        analytics.record(
            .wcTransactionRequestDidAppear(transactionRequest: transactionRequest)
        )
        
        analytics.track(
            .wcTransactionRequestDidAppear(transactionRequest: transactionRequest)
        )
    }
    
    private func disconnectFromTheLedgerIfNeeeded() {
        if !transactions.allSatisfy({ ($0.requestedSigner.account?.requiresLedgerConnection() ?? false) }) {
            return
        }

        wcTransactionSigner.disonnectFromLedger()
    }
}

extension WCMainTransactionScreen {
    private func displaySigningError(_ error: HIPTransactionError) {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: error.debugDescription
        )
    }

    private func displayLedgerError(_ ledgerError: LedgerOperationError) {
        switch ledgerError {
        case .cancelled:
            bannerController?.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized, message: "ble-error-ledger-connection-open-app-error".localized
            )
        case .failedToFetchAddress:
            bannerController?.presentErrorBanner(
                title: "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
        case .failedToFetchAccountFromIndexer:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "ledger-account-fetct-error".localized
            )
        case .failedBLEConnectionError(let state):
            guard let errorTitle = state.errorDescription.title,
                  let errorSubtitle = state.errorDescription.subtitle else {
                return
            }

            bannerController?.presentErrorBanner(
                title: errorTitle,
                message: errorSubtitle
            )

            ledgerConnectionScreen?.dismissScreen()
            ledgerConnectionScreen = nil

            signWithLedgerProcessScreen?.dismissScreen()
            signWithLedgerProcessScreen = nil
        case .ledgerConnectionWarning:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.bannerController?.presentErrorBanner(
                    title: "ble-error-connection-title".localized,
                    message: ""
                )

                self.openLedgerConnectionIssues()
            }
        case let .custom(title, message):
            bannerController?.presentErrorBanner(
                title: title,
                message: message
            )
        default:
            break
        }
    }

    private func displayGenericError() {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: "title-generic-error".localized
        )
    }
}

extension WCMainTransactionScreen {
    private func openLedgerConnection() {
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.wcTransactionSigner.disonnectFromLedger()

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.loadingController?.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension WCMainTransactionScreen {
    private func openLedgerConnectionIssues() {
        transitionToLedgerConnectionIssuesWarning.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-info-green".uiImage,
                    title: "ledger-pairing-issue-error-title".localized,
                    description: .plain("ble-error-fail-ble-connection-repairing".localized),
                    secondaryActionButtonTitle: "title-ok".localized
                )
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension WCMainTransactionScreen {
    private func openSignWithLedgerProcess(ledgerDeviceName: String) {
        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: dataSource.totalTransactionCountToSign
        )

        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancelApproval:
                self.wcTransactionSigner.disonnectFromLedger()

                self.signWithLedgerProcessScreen?.dismissScreen()
                self.signWithLedgerProcessScreen = nil

                self.loadingController?.stopLoading()
            }
        }

        signWithLedgerProcessScreen = transitionToSignWithLedgerProcess.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen
    }
}

extension WCMainTransactionScreen: WCSingleTransactionRequestScreenDelegate {
    func wcSingleTransactionRequestScreenDidReject(_ wcSingleTransactionRequestScreen: WCSingleTransactionRequestScreen) {
        rejectSigning()
    }

    func wcSingleTransactionRequestScreenDidConfirm(_ wcSingleTransactionRequestScreen: WCSingleTransactionRequestScreen) {
        confirmTransaction()
    }
}

extension WCMainTransactionScreen: WCUnsignedRequestScreenDelegate {
    func wcUnsignedRequestScreenDidReject(_ wcUnsignedRequestScreen: WCUnsignedRequestScreen) {
        rejectSigning()
    }

    func wcUnsignedRequestScreenDidConfirm(_ wcUnsignedRequestScreen: WCUnsignedRequestScreen) {
        confirmTransaction()
    }
}

extension WCMainTransactionScreen {
    private func rejectSigning(reason: WCTransactionErrorResponse = .rejected(.user)) {
        if isRejected { return }

        switch reason {
        case .rejected(let rejection):
            if rejection == .user {
                rejectTransaction(with: reason)
            }
        default:
            showRejectionReasonBottomSheet(reason)
        }

        self.isRejected = true
    }

    private func showRejectionReasonBottomSheet(_ reason: WCTransactionErrorResponse) {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "title-error".localized,
            description: .plain("wallet-connect-no-account-for-transaction".localized(params: reason.message)),
            secondaryActionButtonTitle: "title-ok".localized,
            secondaryAction: { [weak self] in
                guard let self = self else {
                    return
                }
                self.rejectTransaction(with: reason)
            }
        )

        asyncMain {
            [weak self] in
            guard let self else { return }
            modalTransition.perform(
                .bottomWarning(configurator: configurator),
                by: .presentWithoutNavigationController
            )
        }
    }

    private func rejectTransaction(with reason: WCTransactionErrorResponse) {
        dataSource.rejectTransaction(reason: reason)
        delegate?.wcMainTransactionScreen(self, didRejected: transactionRequest)
    }
}

extension WCMainTransactionScreen: WCTransactionValidator {
    func rejectTransactionRequest(with error: WCTransactionErrorResponse) {
        rejectSigning(reason: error)
    }
}

extension WCMainTransactionScreen {
    private func getTransactionParams() {
        sharedDataController.getTransactionParams { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case .success(let params):
                self.transactionParams = params
            case .failure:
                break
            }

            self.rejectIfTheNetworkIsInvalid()
        }
    }

    private func rejectIfTheNetworkIsInvalid() {
         if !hasValidNetwork(for: transactions) {
             rejectSigning(reason: .unauthorized(.nodeMismatch))
             return
         }
     }

     private func hasValidNetwork(for transactions: [WCTransaction]) -> Bool {
         guard let params = transactionParams else {
             return false
         }

         return transactions.contains { $0.isInTheSameNetwork(with: params) }
     }
}

extension WCMainTransactionScreen: WCTransactionDappMessageViewDelegate {
    func wcTransactionDappMessageViewDidTapped(
        _ WCTransactionDappMessageView: WCTransactionDappMessageView
    ) {
        guard let session = wcSession else {
            return
        }

        let configurator = WCTransactionFullDappDetailConfigurator(
            from: session,
            option: transactionOption,
            transaction: transactions.first
        )

        modalTransition.perform(
            .wcTransactionFullDappDetail(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }
}

extension WCMainTransactionScreen: WCMainTransactionDataSourceDelegate {
    func wcMainTransactionDataSourceDidFailedGroupingValidation(
        _ wcMainTransactionDataSource: WCMainTransactionDataSource
    ) {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: "title-error".localized,
            description: .plain("wallet-connect-transaction-error-invalid-group".localized),
            secondaryActionButtonTitle: "title-ok".localized,
            secondaryAction: { [weak self] in
                self?.rejectTransaction(with: .rejected(.failedValidation))
            }
        )

        asyncMain {
            [weak self] in
            guard let self else { return }
            modalTransition.perform(
                .bottomWarning(configurator: configurator),
                by: .presentWithoutNavigationController
            )
        }
    }
}

extension WCMainTransactionScreen {
    private func getAssetDetailsIfNeeded() {
        /// <todo> Show blocking loading controller
//            self.loadingController?.startLoadingWithMessage("title-loading".localized)

        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            guard let self else { return }

            var validAssetTransactionAssetIDs: [AssetID] = []
            for transaction in transactions {
                guard let transactionDetail = transaction.transactionDetail else {
                    return
                }

                let isAssetCreation = transactionDetail.isAssetCreationTransaction
                let isAssetTransfer = transactionDetail.isAssetTransaction
                let isAssetConfig = transactionDetail.isAssetConfigTransaction
                let isValidAssetTransaction = !isAssetCreation && (isAssetTransfer || isAssetConfig)

                if isValidAssetTransaction {
                    guard let assetID = transactionDetail.currentAssetId else {
                        rejectSigning(reason: .invalidInput(.asset))
                        break
                    }

                    validAssetTransactionAssetIDs.append(assetID)
                }
            }

            guard !validAssetTransactionAssetIDs.isEmpty else {
                asyncMain {
                    [weak self] in
                    guard let self else { return }
                    loadingController?.stopLoading()
                }
                return
            }

            let uniquedValidAssetTransactionAssetIDs = validAssetTransactionAssetIDs.uniqueElements()
            fetchAssetDetails(with: uniquedValidAssetTransactionAssetIDs) {
                [weak self] isSuccess in
                guard let self else { return }

                asyncMain {
                    [weak self] in
                    guard let self else { return }
                    loadingController?.stopLoading()
                }

                if isSuccess {
                    publishAssetDetailFetchedNotification()
                } else {
                    self.rejectSigning(reason: .invalidInput(.unableToFetchAsset))
                }
            }
        }
    }

    private func publishAssetDetailFetchedNotification() {
        NotificationCenter.default.post(
            name: .AssetDetailFetched,
            object: nil
        )
    }
}

extension WCMainTransactionScreen {
    private func fetchAssetDetails(
        with ids: [AssetID],
        onComplete handler: @escaping (Bool
        ) -> Void) {
        let chunkSize = 100
        let chunkedAssetIDs = ids.chunked(by: chunkSize)
        fetchChunkedAssetDetails(
            chunkedAssetIDs: chunkedAssetIDs,
            onComplete: handler
        )
    }

    private func fetchChunkedAssetDetails(
        chunkedAssetIDs: [[AssetID]],
        onComplete handler: @escaping (Bool) -> Void
    ) {
        let group = DispatchGroup()
        var isAnyFetchFailed = false

        for subAssetIDs in chunkedAssetIDs where !isAnyFetchFailed {
            group.enter()

            fetchAssetDetailsFromIndexer(withIDs: subAssetIDs) {
                [weak self] result in
                guard let self else {
                    return
                }

                switch result {
                case .success(let subAssetDetails):
                    subAssetDetails.forEach {
                        self.sharedDataController.assetDetailCollection[$0.id] = $0
                    }
                    group.leave()
                case .failure:
                    for id in subAssetIDs where !isAnyFetchFailed {
                        group.enter()

                        self.fetchAssetDetailFromNode(id: id) { isSuccess in
                            isAnyFetchFailed = !isSuccess
                            group.leave()
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            handler(!isAnyFetchFailed)
        }
    }

    private func fetchAssetDetailsFromIndexer(
        withIDs ids: [AssetID],
        onComplete handler: @escaping (Result<[AssetDecoration], Error>) -> Void
    ) {
        let draft = AssetFetchQuery(ids: ids, includeDeleted: true)
        let queue = DispatchQueue.global(qos: .userInitiated)
        api!.fetchAssetDetails(
            draft,
            queue: queue,
            ignoreResponseOnCancelled: true
        ) {
            result in
            switch result {
            case .success(let assetList):
                handler(.success(assetList.results))
            case .failure(let apiError, let apiErrorDetail):
                let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                handler(.failure(error))
            }
        }
    }

    private func fetchAssetDetailFromNode(
        id: AssetID,
        onComplete handler: @escaping (Bool) -> Void
    ) {
        let draft = AssetDetailFetchDraft(id: id)
        api!.fetchAssetDetailFromNode(draft) {
            [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let assetDecoration):
                self.sharedDataController.assetDetailCollection[id] = assetDecoration
                handler(true)
            case .failure:
                handler(false)
            }
        }
    }
}
