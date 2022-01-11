// Copyright 2019 Algorand, Inc.

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
//   WCSingleTransactionRequestScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomOverlay

protocol WCSingleTransactionRequestScreenDelegate: AnyObject {
    func wcSingleTransactionRequestScreenDidCompleted(
        _ wcSingleTransactionRequestScreen: WCSingleTransactionRequestScreen
    )
}

final class WCSingleTransactionRequestScreen:
    BaseViewController,
    BottomScrollOverlayFragment {

    weak var delegate: WCSingleTransactionRequestScreenDelegate?
    var isScrollEnabled: Bool = true
    lazy var scrollView: UIScrollView = UIScrollView()

    var assetDetail: AssetDetail?

    private lazy var requestView = WCSingleTransactionRequestView()
    private lazy var viewModel: WCSingleTransactionRequestViewModel? = {
        guard let transaction = transactions.first else {
            return nil
        }

        let account: Account? = session?.accounts.first(matching: (\.address, transaction.transactionDetail?.sender))

        return WCSingleTransactionRequestViewModel(transaction: transaction, account: account)
    }()

    private lazy var theme = Theme()

    private lazy var wcTransactionSigner: WCTransactionSigner = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return WCTransactionSigner(api: api, bannerController: bannerController)
    }()

    private var transactionParams: TransactionParams?

    private var signedTransactions: [Data?] = []

    var transactions: [WCTransaction] {
        dataSource.transactions(at: 0) ?? []
    }

    let dataSource: WCMainTransactionDataSource
    private let wcSession: WCSession?

    init(
        dataSource: WCMainTransactionDataSource,
        configuration: ViewControllerConfiguration
    ) {
        self.dataSource = dataSource
        self.wcSession = configuration.walletConnector.getWalletConnectSession(with: WCURLMeta(wcURL: dataSource.transactionRequest.url))
        super.init(configuration: configuration)
        setTransactionSigners()
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor.uiColor
        scrollView.backgroundColor = theme.backgroundColor.uiColor
        requestView.backgroundColor = theme.backgroundColor.uiColor

        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }

    override func linkInteractors() {
        super.linkInteractors()

        scrollView.delegate = self
        requestView.delegate = self
        wcTransactionSigner.delegate = self
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        title = viewModel?.title
    }

    override func prepareLayout() {
        super.prepareLayout()

        addScrollView()
        addContentView()
    }

    override func bindData() {
        super.bindData()

        requestView.bind(viewModel)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        loadingController?.stopLoading()

        if !transactions.allSatisfy({ ($0.signerAccount?.requiresLedgerConnection() ?? false) }) {
            return
        }

        wcTransactionSigner.disonnectFromLedger()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        validateTransactions(transactions, with: dataSource.groupedTransactions)
        setCacheAssetIfNeeded()
    }

    private func setCacheAssetIfNeeded() {
        guard let transaction = transactions.first,
              (transaction.transactionDetail?.assetId ?? transaction.transactionDetail?.assetIdBeingConfigured) != nil
        else {
            return
        }

        setCachedAsset {
            if self.assetDetail == nil {
                self.rejectSigning()
                self.dismissScreen()
                return
            }

            DispatchQueue.main.async {
                self.viewModel?.middleView?.assetDetail = self.assetDetail
                self.requestView.bind(self.viewModel)
            }
        }
    }
}

extension WCSingleTransactionRequestScreen {
    private func addScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }

    private func addContentView() {
        let contentView = UIView()
        contentView.backgroundColor = theme.backgroundColor.uiColor

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalToSuperview().inset(view.safeAreaBottom).priority(.low)
            make.edges.equalToSuperview()
        }

        contentView.addSubview(requestView)
        requestView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension WCSingleTransactionRequestScreen: UIScrollViewDelegate {
    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        updateLayoutWhenScrollViewDidScroll()
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        updateLayoutWhenScrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }
}

extension WCSingleTransactionRequestScreen: WCSingleTransactionRequestViewDelegate {
    func wcSingleTransactionRequestViewDidTapCancel(_ requestView: WCSingleTransactionRequestView) {
        rejectSigning()
        dismissScreen()

    }

    func wcSingleTransactionRequestViewDidTapConfirm(_ requestView: WCSingleTransactionRequestView) {
        confirmSigning()
    }

    func wcSingleTransactionRequestViewDidTapShowTransaction(_ requestView: WCSingleTransactionRequestView) {

    }

    private func rejectSigning(reason: WCTransactionErrorResponse = .rejected(.user)) {
        rejectTransactionRequest(with: reason)
    }
}

extension WCSingleTransactionRequestScreen: WCTransactionValidator {
    func rejectTransactionRequest(with error: WCTransactionErrorResponse) {
        dataSource.rejectTransaction(reason: error)
        delegate?.wcSingleTransactionRequestScreenDidCompleted(
            self
        )
        dismissScreen()
    }
}

extension WCSingleTransactionRequestScreen: WCTransactionSignerDelegate {
    private func setTransactionSigners() {
        if let session = session {
            transactions.forEach { $0.findSignerAccount(in: session) }
        }
    }

    private func confirmSigning() {
        if let transaction = getFirstSignableTransaction(),
           let index = transactions.firstIndex(of: transaction) {
            fillInitialUnsignedTransactions(until: index)
            signTransaction(transaction)
        }
    }

    private func getFirstSignableTransaction() -> WCTransaction? {
        return transactions.first { transaction in
            transaction.signerAccount != nil
        }
    }

    private func fillInitialUnsignedTransactions(until index: Int) {
        for _ in 0..<index {
            signedTransactions.append(nil)
        }
    }

    private func signTransaction(_ transaction: WCTransaction) {
        if let signerAccount = transaction.signerAccount {
            wcTransactionSigner.signTransaction(transaction, with: dataSource.transactionRequest, for: signerAccount)
        } else {
            signedTransactions.append(nil)
        }
    }

    func wcMainTransactionViewDidDeclineSigning(_ wcMainTransactionView: WCMainTransactionView) {
        if let session = wcSession {
            log(
                WCTransactionDeclinedEvent(
                    transactionCount: transactions.count,
                    dappName: session.peerMeta.name,
                    dappURL: session.peerMeta.url.absoluteString,
                    address: session.walletMeta?.accounts?.first
                )
            )
        }

        rejectSigning()
    }

    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didSign transaction: WCTransaction, signedTransaction: Data) {
        signedTransactions.append(signedTransaction)
        continueSigningTransactions(after: transaction)
    }

    private func continueSigningTransactions(after transaction: WCTransaction) {
        if let nextTransaction = transactions.element(after: transaction) {
            if let signerAccount = nextTransaction.signerAccount {
                wcTransactionSigner.signTransaction(nextTransaction, with: dataSource.transactionRequest, for: signerAccount)
            } else {
                signedTransactions.append(nil)
                continueSigningTransactions(after: nextTransaction)
            }
            return
        }

        if transactions.count != signedTransactions.count {
            rejectSigning(reason: .invalidInput(.unsignable))
            return
        }

        sendSignedTransactions()
    }

    private func sendSignedTransactions() {
        dataSource.signTransactionRequest(signature: signedTransactions)
        logAllTransactions()
        delegate?.wcSingleTransactionRequestScreenDidCompleted(self)
        dismissScreen()
    }

    private func logAllTransactions() {
        transactions.forEach { transaction in
            if let transactionData = transaction.unparsedTransactionDetail,
               let session = wcSession {
                let transactionID = AlgorandSDK().getTransactionID(for: transactionData)
                log(
                    WCTransactionConfirmedEvent(
                        transactionID: transactionID,
                        dappName: session.peerMeta.name,
                        dappURL: session.peerMeta.url.absoluteString
                    )
                )
            }
        }
    }

    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didFailedWith error: WCTransactionSigner.WCSignError) {
        switch error {
        case .api:
            rejectSigning(reason: .rejected(.unsignable))
        case let .ledger(ledgerError):
            showLedgerError(ledgerError)
        }
    }

    private func showLedgerError(_ ledgerError: LedgerOperationError) {
        switch ledgerError {
        case .cancelled:
            bannerController?.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized, message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized, message: "ble-error-ledger-connection-open-app-error".localized
            )
        default:
            break
        }
    }
}

extension WCSingleTransactionRequestScreen: WCSingleTransactionScreenAssetManagable {
}
