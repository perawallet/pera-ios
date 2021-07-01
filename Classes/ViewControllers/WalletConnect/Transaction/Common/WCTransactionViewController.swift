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
//   WCTransactionViewController.swift

import UIKit
import Magpie

class WCTransactionViewController: BaseScrollViewController {
    
    private let layout = Layout<LayoutConstants>()

    private lazy var dappMessageView = WCTransactionDappMessageView()

    var transactionView: WCSingleTransactionView? {
        return nil
    }

    private lazy var confirmButton = MainButton(title: "title-confirm".localized)

    private lazy var declineButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(Colors.ButtonText.tertiary)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitle("title-decline".localized)
    }()

    private lazy var ledgerTransactionOperation: LedgerTransactionOperation = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return LedgerTransactionOperation(api: api)
    }()

    private(set) var transactionParameter: WCTransactionParams
    private(set) var account: Account
    private let transactionRequest: WalletConnectRequest

    init(
        transactionParameter: WCTransactionParams,
        account: Account,
        transactionRequest: WalletConnectRequest,
        configuration: ViewControllerConfiguration
    ) {
        self.transactionParameter = transactionParameter
        self.account = account
        self.transactionRequest = transactionRequest
        super.init(configuration: configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !account.requiresLedgerConnection() {
            return
        }

        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
        ledgerTransactionOperation.stopTimer()
    }

    override func configureAppearance() {
        super.configureAppearance()

        guard let wcSession = walletConnector.getWalletConnectSession(with: WCURLMeta(wcURL: transactionRequest.url)) else {
            return
        }

        dappMessageView.bind(
            WCTransactionDappMessageViewModel(
                session: wcSession,
                imageSize: CGSize(width: 44.0, height: 44.0)
            )
        )
    }

    override func setListeners() {
        super.setListeners()
        dappMessageView.addTarget(self, action: #selector(openLongDappMessageScreen), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmSigningTransaction), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(declineSigningTransaction), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupDappMessageViewLayout()
        setupTransactionViewLayout()
        setupDeclineButtonLayout()
        setupConfirmButtonLayout()
    }
}

extension WCTransactionViewController {
    private func setupDappMessageViewLayout() {
        contentView.addSubview(dappMessageView)

        dappMessageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
        }
    }

    private func setupTransactionViewLayout() {
        guard let transactionView = transactionView else {
            return
        }

        contentView.addSubview(transactionView)

        let bottomInset = view.safeAreaBottom + layout.current.verticalInset * 2 + layout.current.buttonHeight * 2

        transactionView.snp.makeConstraints { make in
            make.top.equalTo(dappMessageView.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(bottomInset)
        }
    }

    private func setupDeclineButtonLayout() {
        view.addSubview(declineButton)

        declineButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.buttonHeight)
            make.bottom.equalToSuperview().inset(view.safeAreaBottom + layout.current.verticalInset)
        }
    }
    
    private func setupConfirmButtonLayout() {
        view.addSubview(confirmButton)

        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalTo(declineButton.snp.top).offset(-layout.current.buttonInset)
        }
    }
}

extension WCTransactionViewController {
    @objc
    private func confirmSigningTransaction() {
        signTransaction()
    }

    @objc
    private func declineSigningTransaction() {
        declineTransaction()
    }

    @objc
    private func openLongDappMessageScreen() {

    }
}

extension WCTransactionViewController: WalletConnectTransactionSignable {
    func signTransaction() {
        if account.requiresLedgerConnection() {
            signLedgerAccountTransaction()
        } else {
            signStandardAccountTransaction()
        }
    }

    func declineTransaction() {
        walletConnector.rejectTransactionRequest(transactionRequest, with: .rejected)
        dismissScreen()
    }
}

extension WCTransactionViewController {
    private func signLedgerAccountTransaction() {
        guard let unsignedTransaction = transactionParameter.unparsedTransaction else {
            return
        }

        ledgerTransactionOperation.setTransactionAccount(account)
        ledgerTransactionOperation.delegate = self
        ledgerTransactionOperation.startTimer()
        ledgerTransactionOperation.setUnsignedTransactionData(unsignedTransaction)
        ledgerTransactionOperation.startScan()
    }

    private func signStandardAccountTransaction() {
        if let signature = session?.privateData(for: account.address) {
            sign(signature, with: SDKTransactionSigner())
        }
    }

    private func sign(_ signature: Data?, with signer: TransactionSigner) {
        signer.delegate = self

        guard let unsignedTransaction = transactionParameter.unparsedTransaction,
              let signedTransaction = signer.sign(unsignedTransaction, with: signature) else {
            return
        }

        walletConnector.signTransactionRequest(transactionRequest, with: [signedTransaction])
        self.dismissScreen()
    }
}

extension WCTransactionViewController: LedgerTransactionOperationDelegate {
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didReceiveSignature data: Data) {
        sign(data, with: LedgerTransactionSigner(account: account))
    }

    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didFailed error: LedgerOperationError) {
        switch error {
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

extension WCTransactionViewController: TransactionSignerDelegate {
    func transactionSigner(_ transactionSigner: TransactionSigner, didFailedSigning error: HIPError<TransactionError>) {
        declineTransaction()
    }
}

extension WCTransactionViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let buttonInset: CGFloat = 16.0
        let buttonHeight: CGFloat = 52.0
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 16.0
    }
}

protocol WalletConnectTransactionSignable: AnyObject {
    func signTransaction()
    func declineTransaction()
}

enum WCTransactionType {
    case algos
    case asset
    case assetAddition
    case group
    case appCall
}
