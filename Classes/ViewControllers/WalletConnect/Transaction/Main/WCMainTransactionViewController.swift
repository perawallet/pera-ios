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
//   WCMainTransactionViewController.swift

import UIKit
import Magpie
import SVProgressHUD

class WCMainTransactionViewController: BaseViewController {

    private lazy var mainTransactionView = WCMainTransactionView()

    private lazy var dappMessageModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 350.0))
    )

    private lazy var dataSource = WCMainTransactionDataSource(
        transactions: transactions,
        transactionRequest: transactionRequest,
        transactionOption: transactionOption,
        session: session,
        walletConnector: walletConnector
    )

    private lazy var layoutBuilder = WCMainTransactionLayout(dataSource: dataSource)

    private lazy var wcTransactionSigner: WCTransactionSigner = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return WCTransactionSigner(api: api)
    }()

    private let transactions: [WCTransaction]
    private let transactionRequest: WalletConnectRequest
    private let wcSession: WCSession?
    private let transactionOption: WCTransactionOption?

    private var signedTransactions: [Data?] = []

    init(
        transactions: [WCTransaction],
        transactionRequest: WalletConnectRequest,
        transactionOption: WCTransactionOption?,
        configuration: ViewControllerConfiguration
    ) {
        self.transactions = transactions
        self.transactionRequest = transactionRequest
        self.transactionOption = transactionOption
        self.wcSession = configuration.walletConnector.getWalletConnectSession(with: WCURLMeta(wcURL: transactionRequest.url))
        super.init(configuration: configuration)
        setTransactionSigners()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getAssetDetailsIfNeeded()
        validateTransactions(transactions, with: dataSource.groupedTransactions)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !transactions.allSatisfy({ ($0.signerAccount?.requiresLedgerConnection() ?? false) }) {
            return
        }

        wcTransactionSigner.disonnectFromLedger()
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "wallet-connect-transaction-title-unsigned".localized
    }

    override func linkInteractors() {
        mainTransactionView.delegate = self
        mainTransactionView.setDataSource(dataSource)
        mainTransactionView.setDelegate(layoutBuilder)
        dataSource.delegate = self
        layoutBuilder.delegate = self
        wcTransactionSigner.delegate = self
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(mainTransactionView)
    }

    override func bindData() {
        super.bindData()
        mainTransactionView.bind(WCMainTransactionViewModel(transactions: transactions))
    }
}

extension WCMainTransactionViewController {
    private func setTransactionSigners() {
        if let session = session {
            transactions.forEach { $0.findSignerAccount(in: session) }
        }
    }
}

extension WCMainTransactionViewController: WCTransactionValidator {
    func rejectTransactionRequest(with error: WCTransactionErrorResponse) {
        walletConnector.rejectTransactionRequest(transactionRequest, with: error)
        dismissScreen()
    }
}

extension WCMainTransactionViewController: WCMainTransactionViewDelegate {
    func wcMainTransactionViewDidConfirmSigning(_ wcMainTransactionView: WCMainTransactionView) {
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
            wcTransactionSigner.signTransaction(transaction, with: transactionRequest, for: signerAccount)
        } else {
            signedTransactions.append(nil)
        }
    }

    func wcMainTransactionViewDidDeclineSigning(_ wcMainTransactionView: WCMainTransactionView) {
        rejectTransactionRequest(with: .rejected)
    }
}

extension WCMainTransactionViewController: WCTransactionSignerDelegate {
    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didSign transaction: WCTransaction, signedTransaction: Data) {
        signedTransactions.append(signedTransaction)

        if let index = transactions.firstIndex(of: transaction),
           let nextTransaction = transactions.nextElement(afterElementAt: index) {
            signTransaction(nextTransaction)
            return
        }

        if transactions.count != signedTransactions.count {
            rejectTransactionRequest(with: .rejected)
            return
        }

        walletConnector.signTransactionRequest(transactionRequest, with: signedTransactions)
        dismissScreen()
    }

    func wcTransactionSigner(_ wcTransactionSigner: WCTransactionSigner, didFailedWith error: WCTransactionSigner.WCSignError) {
        switch error {
        case .api:
            rejectTransactionRequest(with: .rejected)
        case let .ledger(ledgerError):
            showLedgerError(ledgerError)
        }
    }

    private func showLedgerError(_ ledgerError: LedgerOperationError) {
        switch ledgerError {
        case .cancelled:
            NotificationBanner.showError(
                "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            NotificationBanner.showError(
                "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        default:
            break
        }
    }
}

extension WCMainTransactionViewController: WCMainTransactionLayoutDelegate {
    func wcMainTransactionLayout(
        _ wcMainTransactionLayout: WCMainTransactionLayout,
        didSelect transactions: [WCTransaction]
    ) {
        if transactions.count == 1 {
            if let transaction = transactions.first {
                presentSingleWCTransaction(transaction, with: transactionRequest)
            }

            return
        }

        open(.wcGroupTransaction(transactions: transactions, transactionRequest: transactionRequest), by: .push)
    }
}

extension WCMainTransactionViewController: WalletConnectSingleTransactionRequestPresentable { }

extension WCMainTransactionViewController: AssetCachable {
    private func getAssetDetailsIfNeeded() {
        for (index, transaction) in transactions.enumerated() where transaction.transactionDetail?.type != .payment {
            if !SVProgressHUD.isVisible() {
                SVProgressHUD.show(withStatus: "title-loading".localized)
            }

            guard let assetId = transaction.transactionDetail?.assetId else {
                if transaction.transactionDetail?.type == .assetTransfer {
                    SVProgressHUD.showError(withStatus: "title-done".localized)
                    SVProgressHUD.dismiss()
                    self.rejectTransactionRequest(with: .invalidInput)
                    return
                }
                continue
            }

            cacheAssetDetail(with: assetId) { assetDetail in
                if assetDetail == nil {
                    SVProgressHUD.showError(withStatus: "title-done".localized)
                    SVProgressHUD.dismiss()
                    self.rejectTransactionRequest(with: .invalidInput)
                    return
                }

                if index == self.transactions.count - 1 {
                    SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                    SVProgressHUD.dismiss()
                    self.mainTransactionView.reloadData()
                }
            }
        }
    }
}

extension WCMainTransactionViewController: WCMainTransactionDataSourceDelegate {
    func wcMainTransactionDataSourceDidFailedGroupingValidation(_ wcMainTransactionDataSource: WCMainTransactionDataSource) {
        rejectTransactionRequest(with: .rejected)
    }

    func wcMainTransactionDataSourceDidOpenLongDappMessageView(_ wcMainTransactionDataSource: WCMainTransactionDataSource) {
        guard let wcSession = wcSession,
              let message = transactionOption?.message else {
            return
        }

        open(
            .wcTransactionFullDappDetail(
                wcSession: wcSession,
                message: message
            ),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: dappMessageModalPresenter
            )
        )
    }
}

enum WCTransactionType {
    case algos
    case asset
    case assetAddition
    case appCall
}
