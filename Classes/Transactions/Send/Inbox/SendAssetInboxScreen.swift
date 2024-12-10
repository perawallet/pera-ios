// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SendAssetInboxScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class SendAssetInboxScreen: BaseScrollViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var sendTransactionController = ARC59TransactionSendController(
        account: draft.sender,
        api: api!,
        transactionSigner: transactionSigner
    )

    private lazy var titleView = UILabel()
    private lazy var iconView = UIImageView()
    private lazy var subtitleView = ALGActiveLabel()
    private lazy var contextView = UIView()
    private lazy var amountInformationView = SecondaryListItemView()
    private lazy var feeInformationView = SecondaryListItemView()
    private lazy var descriptionView = UILabel()
    private lazy var sendActionView = MacaroonUIKit.Button()
    private lazy var closeActionView = MacaroonUIKit.Button()

    private lazy var transitionToWarning = BottomSheetTransition(presentingViewController: self)
    private var transitionToSignWithLedger: BottomSheetTransition?
    private var transitionToLedgerSigningProcess: BottomSheetTransition?
    private var transitionToLedgerConnection: BottomSheetTransition?
    private var transitionToLedgerConnectionIssuesWarning: BottomSheetTransition?
    
    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?
    
    private var visibleScreen: UIViewController {
        return findVisibleScreen()
    }

    private let draft: SendAssetInboxDraft
    private let transactionSigner: SwapTransactionSigner
    private let theme: SendAssetInboxScreenTheme
    
    private let viewModel: SendAssetInboxScreenViewModel
    
    private var inboxSendSummary: AssetInboxSendSummary?
    private var loadingScreen: LoadingScreen?
    
    init(
        draft: SendAssetInboxDraft,
        transactionSigner: SwapTransactionSigner,
        theme: SendAssetInboxScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.transactionSigner = transactionSigner
        self.theme = theme
        self.viewModel =  SendAssetInboxScreenViewModel(
            asset: draft.asset,
            amount: draft.amount,
            fee: nil
        )
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
        contextView.customizeAppearance(theme.context)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addTitle()
        addIcon()
        addSubtitle()
        addContext()
        addAmountInformation()
        addFeeInformation()
        addDescription()
        addSendAction()
        addCloseAction()
    }
}

extension SendAssetInboxScreen {
    private func addTitle() {
        contentView.addSubview(titleView)
        titleView.customizeAppearance(theme.title)

        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == theme.titleTopPadding
            $0.leading == theme.titleHorizontalPadding
            $0.trailing == theme.titleHorizontalPadding
        }
        
        viewModel.title?.load(in: titleView)
     }
    
    private func addIcon() {
        contentView.addSubview(iconView)
        iconView.customizeAppearance(theme.icon)

        iconView.snp.makeConstraints {
            $0.top == titleView.snp.bottom - theme.iconTopSpacing
            $0.leading == 0
            $0.trailing == 0
            $0.centerX == 0
        }
    }
    
    private func addSubtitle() {
        contentView.addSubview(subtitleView)
        subtitleView.customizeAppearance(theme.subtitle)

        subtitleView.fitToIntrinsicSize()
        subtitleView.snp.makeConstraints {
            $0.top == iconView.snp.bottom - theme.subtitleTopPadding
            $0.leading == theme.titleHorizontalPadding
            $0.trailing == theme.titleHorizontalPadding
        }
        
        bindSubtitle()
    }
    
    private func addContext() {
        contentView.addSubview(contextView)

        contextView.snp.makeConstraints {
            $0.top == subtitleView.snp.bottom + theme.contextTopPadding
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addAmountInformation() {
        amountInformationView.customize(theme.amountInformationView)

        contextView.addSubview(amountInformationView)
        amountInformationView.snp.makeConstraints {
            $0.top == theme.spacingBetweenActions
            $0.leading == 0
            $0.trailing == 0
        }
        
        amountInformationView.bindData(viewModel.assetInformationViewModel)
    }
    
    private func addFeeInformation() {
        feeInformationView.customize(theme.feeInformationView)

        let topSeparator = addSeparator(to: amountInformationView)

        contextView.addSubview(feeInformationView)
        feeInformationView.snp.makeConstraints {
            $0.top == topSeparator.snp.bottom + theme.spacingBetweenSecondaryListItemAndSeparator
            $0.leading == 0
            $0.trailing == 0
        }
        
        feeInformationView.bindData(viewModel.feeInformationViewModel)
    }
    
    private func addDescription() {
        descriptionView.customizeAppearance(theme.description)

        contextView.addSubview(descriptionView)
        descriptionView.fitToIntrinsicSize()
        descriptionView.snp.makeConstraints {
            $0.top == feeInformationView.snp.bottom + theme.descriptionTopPadding
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
        
        viewModel.description?.load(in: descriptionView)
    }
    
    private func addSendAction() {
        sendActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        sendActionView.customizeAppearance(theme.sendActionView)

        contextView.addSubview(sendActionView)
        sendActionView.snp.makeConstraints {
            $0.top >= descriptionView.snp.bottom + theme.actionsContentEdgeInsets.top
            $0.leading == theme.actionsContentEdgeInsets.leading
            $0.trailing == theme.actionsContentEdgeInsets.trailing
        }

        sendActionView.addTouch(
            target: self,
            action: #selector(didSend)
        )
    }
    
    private func addCloseAction() {
        closeActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        closeActionView.customizeAppearance(theme.closeActionView)

        contextView.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.top == sendActionView.snp.bottom + theme.spacingBetweenActions
            $0.leading == theme.actionsContentEdgeInsets.leading
            $0.trailing == theme.actionsContentEdgeInsets.trailing
            $0.bottom == theme.actionsContentEdgeInsets.bottom + theme.closeActionBottomPadding
        }

        closeActionView.addTouch(
            target: self,
            action: #selector(didClose)
        )
    }
}

extension SendAssetInboxScreen {
    private func bindSubtitle() {
        guard let subtitle = viewModel.subtitle else {
            subtitleView.text = nil
            subtitleView.attributedText = nil
            return
        }

        if let highlightedText = viewModel.highlightedSubtitleText {
            let hyperlink: ALGActiveType = .word(highlightedText.text)
            subtitleView.attachHyperlink(
                hyperlink,
                to: subtitle,
                attributes: highlightedText.attributes
            ) {
                [unowned self] in
                self.readMore()
            }

            return
        }

        subtitle.load(in: subtitleView)
    }
    
    private func addSeparator(to view: UIView) -> UIView {
        return contextView.attachSeparator(
            theme.separator,
            to: view,
            margin: theme.spacingBetweenSecondaryListItemAndSeparator
        )
    }
}

extension SendAssetInboxScreen {
    private func fetchData() {
        let assetInboxSendDraft = AssetInboxSendDraft(
            account: draft.receiver,
            assetID: draft.asset.id
        )
        
        startLoading()
        
        api?.fetchASASendInboxSummary(draft: assetInboxSendDraft) { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case let .success(summary):
                self.inboxSendSummary = summary
                let viewModel = ARC59SendFeeInformationViewModel(fee: summary.totalProtocolFee)
                self.feeInformationView.bindData(viewModel)
                self.stopLoading()
            case let .failure(error, _):
                self.stopLoading()
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: error.localizedDescription
                )
                self.didClose()
            }
        }
    }
}

extension SendAssetInboxScreen {
    private func sendTransaction() {
        sendTransactionController.eventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .didSignTransaction:
                if self.draft.sender.requiresLedgerConnection(),
                   let signWithLedgerProcessScreen = self.signWithLedgerProcessScreen {
                    signWithLedgerProcessScreen.increaseProgress()

                    if signWithLedgerProcessScreen.isProgressFinished {
                        self.stopLoading()
                        openLoading()
                    }
                }
            case .didSignAllTransactions:
                break
            case .didCompleteTransactionOnTheNode(let id):
                self.openSuccess(id)
            case let .didFailTransaction(id):
                loadingScreen?.popScreen()
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "send-inbox-transaction-failed".localized(id)
                )
            case let .didFailNetwork(error):
                let message: String
                switch error {
                case .client(_, let apiError):
                    message = apiError?.message ?? apiError.debugDescription
                case .server(_, let apiError):
                    message = apiError?.message ?? apiError.debugDescription
                case .connection(let error):
                    message = error.debugDescription
                case .unexpected(let error):
                    message = error.debugDescription
                }
                
                loadingScreen?.popScreen()
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: message
                )
                break
            case .didCancelTransaction:
                loadingScreen?.popScreen()
                break
            case let .didFailSigning(error):
                self.sendTransactionController.clearTransactions()
                loadingScreen?.popScreen()
                switch error {
                case .api(let apiError):
                    self.displaySigningError(apiError)
                case .ledger(let ledgerError):
                    self.displayLedgerError(ledgerError)
                }
            case let .didLedgerRequestUserApproval(ledger, transactions):
                self.openSignWithLedgerProcess(
                    ledger: ledger,
                    transactions: transactions
                )
            case .didFinishTiming:
                break
            case .didLedgerReset:
                self.sendTransactionController.clearTransactions()
                self.stopLoading()

                if self.visibleScreen is LedgerConnectionScreen {
                    self.ledgerConnectionScreen?.dismissScreen()
                    self.ledgerConnectionScreen = nil
                    return
                }

                if self.visibleScreen is SignWithLedgerProcessScreen {
                    self.signWithLedgerProcessScreen?.dismissScreen()
                    self.signWithLedgerProcessScreen = nil
                }
            case .didLedgerResetOnSuccess:
                break
            case .didLedgerRejectSigning:
                break
            }
        }
        
        getTransactionParamsAndComposeRelatedTransactions()
    }
}

extension SendAssetInboxScreen {
    private func openLoading() {
        loadingScreen = open(
            .loading(viewModel: IncomingASAsDetailLoadingScreenViewModel()),
            by: .push
        ) as? LoadingScreen
    }

    private func openSuccess(
        _ transactionId: String?
    ) {
        let successResultScreenViewModel = IncomingASAsDetailSuccessResultScreenViewModel(
            title: "incoming-asas-detail-success-title"
                .localized,
            detail: "incoming-asas-detail-success-detail"
                .localized
        )
        let successScreen = loadingScreen?.open(
            .successResultScreen(viewModel: successResultScreenViewModel),
            by: .push,
            animated: false
        ) as? SuccessResultScreen

        successScreen?.eventHandler = {
            [weak self, weak successScreen] event in
            guard let self = self else { return }

            switch event {
            case .didTapViewDetailAction:
                self.openPeraExplorerForTransaction(transactionId)
            case .didTapDoneAction:
                successScreen?.dismissScreen { [weak self] in
                    guard let self else { return }
                    eventHandler?(.send)
                }
            }
        }
    }

    private func openPeraExplorerForTransaction(
        _ transactionID: String?
    ) {
        guard let identifierlet = transactionID,
              let url = AlgoExplorerType.peraExplorer.transactionURL(
                with: identifierlet,
                in: api?.network ?? .mainnet
              ) else {
            return
        }

        open(url)
    }
}

extension SendAssetInboxScreen {
    @objc
    private func readMore() {
        eventHandler?(.readMore(self.inboxSendSummary?.warningMessage?.link))
    }
    
    @objc
    private func didSend() {
        guard let inboxSendSummary else {
            return
        }
        let configuratorDescription =
        BottomWarningViewConfigurator.BottomWarningDescription.custom(
            description: (inboxSendSummary.warningMessage?.detail ?? "", []),
            markedWordWithHandler: (
                word: inboxSendSummary.warningMessage?.readMore ?? "",
                handler: {
                    [weak self] in
                    guard let self else { return }
                    self.dismiss(animated: true) {
                        [weak self] in
                        guard let self else { return }
                        if let url = URL(
                            string: inboxSendSummary.warningMessage?.link ?? ""
                        ) {
                            self.open(url)
                        }
                    }
                }
            )
        )

        transitionToWarning.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-incoming-asa-yellow-error".uiImage,
                    title: inboxSendSummary.warningMessage?.title ?? "",
                    description: configuratorDescription,
                    primaryActionButtonTitle: "title-i-understand".localized,
                    secondaryActionButtonTitle: "title-cancel".localized,
                    primaryAction: { [weak self] in
                        guard let self else { return }
                        self.sendTransaction()
                    }
                )
            ),
            by: .presentWithoutNavigationController
        )
    }

    @objc
    private func didClose() {
        eventHandler?(.close)
    }
}

extension SendAssetInboxScreen {
    private func getTransactionParamsAndComposeRelatedTransactions() {
        if !draft.sender.requiresLedgerConnection() {
            openLoading()
        }

        sharedDataController.getTransactionParams { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let params):
                guard let transactions = composeTransactions(params) else {
                    self.loadingScreen?.popScreen()
                    self.bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "send-inbox-transaction-composing-failed".localized
                    )
                    return
                }
                
                sendTransactionController.signTransactionGroups(transactions)
            case .failure(let error):
                self.loadingScreen?.popScreen()
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: error.localizedDescription
                )
            }
        }
    }
    
    private func composeTransactions(_ params: TransactionParams) -> [[Data]]? {
        guard let inboxSendSummary else {
            return nil
        }
        
        let transactionDraft = AssetTransactionARC59SendDraft(
            from: draft.sender,
            toAccount: Account(address: draft.receiver),
            asset: draft.asset,
            amount: draft.amount,
            assetIndex: draft.asset.id,
            assetDecimalFraction: draft.asset.decimals,
            appAddress: draft.appAddress,
            inboxAccount: inboxSendSummary.inboxAddress,
            minBalance: inboxSendSummary.minBalanceAmount,
            innerTransactionCount: inboxSendSummary.innerTransactionCount,
            appID: draft.appID,
            extraAlgoAmount: inboxSendSummary.algoFundAmount,
            isOptedInToProtocol: inboxSendSummary.isOptedInToProtocol
        )
        
        let dataBuilder = ARC59SendTransactionDataBuilder(
            params: params,
            draft: transactionDraft
        )
        
        guard let sendTransactions = dataBuilder.composeSendTransactionData() else {
            return nil
        }
        
        return [sendTransactions]
    }
}

extension SendAssetInboxScreen {
     private func openSignWithLedgerConfirmation() {
        let transition = BottomSheetTransition(presentingViewController: self)

        let totalTransactionCountToSign = 3 // transactionGroups.reduce(0, { $0 + $1.transactionsToSign.count })

        let title =
            "swap-sign-with-ledger-title"
                .localized
                .bodyLargeMedium(alignment: .center)
        let highlightedBodyPart =
            "swap-sign-with-ledger-body-highlighted"
                .localized(params: "\(totalTransactionCountToSign)")
        let body =
            "swap-sign-with-ledger-body"
                .localized(params: "\(totalTransactionCountToSign)")
                .bodyRegular(alignment: .center)
                .addAttributes(
                    to: highlightedBodyPart,
                    newAttributes: Typography.bodyMediumAttributes(alignment: .center)
                )

        let uiSheet = UISheet(
            image: "icon-ledger-48",
            title: title,
            body: UISheetBodyTextProvider(text: body)
        )

        let signTransactionsAction = UISheetAction(
            title: "swap-sign-with-ledger-action-title".localized,
            style: .default
        ) { [weak self] in
            guard let self = self else { return }
            
            self.startLoading()
            self.openLedgerConnection()
            self.getTransactionParamsAndComposeRelatedTransactions()
        }
         
        uiSheet.addAction(signTransactionsAction)

         transition.perform(
            .sheetAction(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme()
            ),
            by: .presentWithoutNavigationController
        )

        transitionToSignWithLedger = transition
    }

    private func openLedgerConnection() {
        let transition = BottomSheetTransition(presentingViewController: self)

        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.sendTransactionController.clearTransactions()
                self.sendTransactionController.disconnectFromLedger()

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.stopLoading()
            }
        }

        ledgerConnectionScreen = transition.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )

        transitionToLedgerConnection = transition
    }

    private func openLedgerConnectionIssues() {
        let transition = BottomSheetTransition(presentingViewController: self)

        transition.perform(
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

        transitionToLedgerConnectionIssuesWarning = transition
    }
    
    private func openSignWithLedgerProcess(
        ledger: String,
        transactions: [[Data]]
    ) {
        if visibleScreen is SignWithLedgerProcessScreen {
            return
        }

        let transition = BottomSheetTransition(
            presentingViewController: self,
            interactable: false
        )

        let totalTransactionCount = transactions.reduce(0, { $0 + $1.count })

        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledger,
            totalTransactionCount: totalTransactionCount
        )

        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancelApproval:
                self.sendTransactionController.clearTransactions()
                self.sendTransactionController.disconnectFromLedger()

                self.visibleScreen.dismissScreen()
                self.signWithLedgerProcessScreen = nil

                self.stopLoading()
            }
        }

        signWithLedgerProcessScreen = transition.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen

        transitionToLedgerSigningProcess = transition
    }

    private func displaySigningError(
        _ error: HIPTransactionError
    ) {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: error.debugDescription
        )
    }

    private func displayLedgerError(_ ledgerError: LedgerOperationError) {
        guard let bannerController else { return }
        switch ledgerError {
        case .cancelled:
            bannerController.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            bannerController.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        case .failedToFetchAddress:
            bannerController.presentErrorBanner(
                title: "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
        case .failedToFetchAccountFromIndexer:
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: "ledger-account-fetct-error".localized
            )
        case .custom(let title, let message):
            bannerController.presentErrorBanner(
                title: title,
                message: message
            )
        case .failedBLEConnectionError(let state):
            guard let errorTitle = state.errorDescription.title,
                  let errorSubtitle = state.errorDescription.subtitle else {
                return
            }

            sendTransactionController.clearTransactions()
            stopLoading()

            if visibleScreen is LedgerConnectionScreen {
                ledgerConnectionScreen?.dismissScreen()
                ledgerConnectionScreen = nil
            } else if visibleScreen is SignWithLedgerProcessScreen {
                signWithLedgerProcessScreen?.dismissScreen()
                signWithLedgerProcessScreen = nil
            }

            bannerController.presentErrorBanner(
                title: errorTitle,
                message: errorSubtitle
            )
        case .ledgerConnectionWarning:
            func showLedgerConnectionIssue() {
                bannerController.presentErrorBanner(
                    title: "ble-error-connection-title".localized,
                    message: ""
                )

                self.openLedgerConnectionIssues()
            }
            
            if let ledgerConnectionScreen {
                ledgerConnectionScreen.dismiss(animated: true) {
                    self.ledgerConnectionScreen = nil

                    self.sendTransactionController.clearTransactions()
                    self.stopLoading()
                    showLedgerConnectionIssue()
                }
            } else {
                showLedgerConnectionIssue()
            }
            
        default:
            break
        }
    }
}

extension SendAssetInboxScreen {
    private func startLoading() {
        loadingController?.startLoadingWithMessage("title-loading".localized)
    }

    private func stopLoading() {
        loadingController?.stopLoading()
    }
}

extension SendAssetInboxScreen {
    enum Event {
        case readMore(_ urlString: String?)
        case send
        case close
    }
}
