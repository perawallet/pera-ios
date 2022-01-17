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
//  SendAlgosTransactionPreviewViewController.swift

import UIKit

class SendAlgosTransactionPreviewViewController: SendTransactionPreviewViewController, TestNetTitleDisplayable {
    
    private lazy var bottomModalTransition = BottomSheetTransition(presentingViewController: self)
    
    private let viewModel: SendAlgosTransactionPreviewViewModel
    
    override var filterOption: OldSelectAssetViewController.FilterOption {
        return .algos
    }
    
    override init(
        account: Account?,
        assetReceiverState: AssetReceiverState,
        isSenderEditable: Bool,
        qrText: QRText?,
        configuration: ViewControllerConfiguration
    ) {
        viewModel = SendAlgosTransactionPreviewViewModel(isAccountSelectionEnabled: isSenderEditable)
        super.init(
            account: account,
            assetReceiverState: assetReceiverState,
            isSenderEditable: isSenderEditable,
            qrText: qrText,
            configuration: configuration
        )
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(sendTransactionPreviewView, with: selectedAccount)
        configureTransactionReceiver()
        displayTestNetTitleView(with: "send-algos-title".localized)
    }
    
    override func presentAccountList(accountSelectionState: AccountSelectionState) {
        accountListModalTransition.perform(
            .accountList(
                mode: accountSelectionState == .sender ? .transactionSender(assetDetail: nil) : .transactionReceiver(assetDetail: nil),
                delegate: self
            ),
            by: .presentWithoutNavigationController
        )
    }
    
    override func configure(forSelected account: Account, with assetDetail: AssetDetail?) {
        selectedAccount = account
        viewModel.configure(sendTransactionPreviewView, with: selectedAccount)
        sendTransactionPreviewView.setAssetSelectionHidden(true)
    }
    
    override func displayTransactionPreview() {
        guard let selectedAccount = selectedAccount else {
            displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        if !sendTransactionPreviewView.transactionReceiverView.addressText.isEmpty {
            switch assetReceiverState {
            case .contact:
                break
            default:
                assetReceiverState = .address(
                    address: sendTransactionPreviewView.transactionReceiverView.addressText,
                    amount: nil
                )
            }
        }

        if let algosAmountText = sendTransactionPreviewView.amountInputView.inputTextField.text,
           let decimalAmount = algosAmountText.decimalAmount {
            amount = decimalAmount
        }

        if !isTransactionValid() {
            displaySimpleAlertWith(
                title: "send-algos-alert-incomplete-title".localized,
                message: "send-algos-alert-message-address".localized
            )
            return
        }
            
        if selectedAccount.amount <= UInt64(amount.toMicroAlgos) && !isMaxTransaction {
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-amount-error".localized)
            return
        }
            
        if !isMaxTransaction {
            if Int(selectedAccount.amount) - Int(amount.toMicroAlgos) - Int(minimumFee) < minimumTransactionMicroAlgosLimit {
                self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-minimum-amount-error".localized)
                return
            }
        }
            
        if isMaxTransaction {
            if selectedAccount.doesAccountHasParticipationKey() {
                presentParticipationKeyWarningForMaxTransaction()
                return
            } else if selectedAccount.hasMinAmountFields || isMaxTransactionFromRekeyedAccount {
                displayMaxTransactionWarning()
                return
            }
        }

        composeTransactionData()
    }
    
    override func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        guard let algosTransactionDraft = draft as? AlgosTransactionSendDraft else {
            return
        }
        
        open(
            .sendAlgosTransaction(
                algosTransactionSendDraft: algosTransactionDraft,
                transactionController: transactionController,
                receiver: assetReceiverState,
                isSenderEditable: isSenderEditable
            ),
            by: .push
        )
    }
    
    override func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        guard let qrAddress = qrText.address else {
            return
        }
        sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: nil)
        if let amountFromQR = qrText.amount {
            displayQRAlert(for: amountFromQR, with: qrText.asset)
        }
        assetReceiverState = .address(address: qrAddress, amount: nil)

        if let lockedNote = qrText.lockedNote,
           !lockedNote.isEmpty {
            sendTransactionPreviewView.noteInputView.value = lockedNote
            sendTransactionPreviewView.noteInputView.setEnabled(false)
        } else if let note = qrText.note,
           !note.isEmpty {
            sendTransactionPreviewView.noteInputView.value = note
            sendTransactionPreviewView.noteInputView.setEnabled(true)
        }
        
        if let handler = completionHandler {
            handler()
        }
    }
    
    override func updateSelectedAccountForSender(_ account: Account) {
        viewModel.update(sendTransactionPreviewView, with: account, isMaxTransaction: isMaxTransaction)
    }
    
    private func displayQRAlert(for amountFromQR: UInt64, with asset: Int64?) {
        let bottomWarningViewConfigurator = BottomWarningViewConfigurator(
            image: "icon-qr-alert".uiImage,
            title: "send-qr-scan-alert-title".localized,
            description: "send-qr-scan-alert-message".localized,
            primaryActionButtonTitle: "title-approve".localized,
            secondaryActionButtonTitle: "title-cancel".localized,
            primaryAction: { [weak self] in
                guard let self = self else {
                    return
                }
                if asset != nil {
                    self.displaySimpleAlertWith(title: "", message: "send-qr-different-asset-alert".localized)
                    return
                }
                let receivedAmount = amountFromQR.toAlgos
                self.amount = receivedAmount
                self.sendTransactionPreviewView.amountInputView.inputTextField.text = receivedAmount.toDecimalStringForAlgosInput
                return
            }
        )

        bottomModalTransition.perform(
            .bottomWarning(configurator: bottomWarningViewConfigurator),
            by: .presentWithoutNavigationController
        )
    }

    private func displayMaxTransactionWarning() {
        guard let account = selectedAccount else {
            return
        }

        bottomModalTransition.perform(
            .maximumBalanceWarning(account: account, delegate: self),
            by: .presentWithoutNavigationController
        )
    }
}

extension SendAlgosTransactionPreviewViewController: MaximumBalanceWarningViewControllerDelegate {
    func maximumBalanceWarningViewControllerDidConfirmWarning(_ maximumBalanceWarningViewController: MaximumBalanceWarningViewController) {
        maximumBalanceWarningViewController.dismissScreen()
        composeTransactionData()
    }
}

extension SendAlgosTransactionPreviewViewController {
    private func configureTransactionReceiver() {
        switch assetReceiverState {
        case .initial:
            amount = 0.00
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        case let .address(_, amount):
            if let sendAmount = amount,
                let amountInt = UInt64(sendAmount) {
                
                self.amount = amountInt.toAlgos
                sendTransactionPreviewView.amountInputView.inputTextField.text = self.amount.toAlgosStringForLabel
            }
            
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        case .myAccount, .contact:
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        }
    }
}

extension SendAlgosTransactionPreviewViewController {
    private func presentParticipationKeyWarningForMaxTransaction() {
        let alertController = UIAlertController(
            title: "send-algos-account-delete-title".localized,
            message: "send-algos-account-delete-body".localized,
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel)

        let proceedAction = UIAlertAction(title: "title-proceed".localized, style: .destructive) { _ in
            self.displayMaxTransactionWarning()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(proceedAction)

        present(alertController, animated: true, completion: nil)
    }

    private func composeTransactionData() {
        transactionController.delegate = self
        guard let selectedAccount = selectedAccount else {
            return
        }
        
        if amount.toMicroAlgos < minimumTransactionMicroAlgosLimit {
            var receiverAddress: String
                   
            switch assetReceiverState {
            case let .address(address, _):
                receiverAddress = address
            case let .contact(contact):
                guard let contactAddress = contact.address else {
                    self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-contact-not-found".localized)
                    return
                }
                receiverAddress = contactAddress
            case let .myAccount(myAccount):
                receiverAddress = myAccount.address
            case .initial:
                self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-address-not-selected".localized)
                return
            }
                   
            receiverAddress = receiverAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !AlgorandSDK().isValidAddress(receiverAddress) {
                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "send-algos-receiver-address-validation".localized
                )
                return
            }
            
            let receiverFetchDraft = AccountFetchDraft(publicKey: receiverAddress)
                   
            loadingController?.startLoadingWithMessage("title-loading".localized)
            self.api?.fetchAccount(receiverFetchDraft, queue: .main) { accountResponse in
                if !selectedAccount.requiresLedgerConnection() {
                    self.loadingController?.stopLoading()
                }
                
                switch accountResponse {
                case let .failure(error, _):
                    if error.isHttpNotFound {
                        self.loadingController?.stopLoading()
                        self.displaySimpleAlertWith(
                            title: "title-error".localized,
                            message: "send-algos-minimum-amount-error-new-account".localized
                        )
                    } else {
                        self.loadingController?.stopLoading()
                        self.displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
                    }
                case let .success(accountWrapper):
                    if !accountWrapper.account.isSameAccount(with: receiverAddress) {
                        self.loadingController?.stopLoading()
                        UIApplication.shared.firebaseAnalytics?.record(
                            MismatchAccountErrorLog(requestedAddress: receiverAddress, receivedAddress: accountWrapper.account.address)
                        )
                        return
                    }

                    accountWrapper.account.assets = accountWrapper.account.nonDeletedAssets()
                    if accountWrapper.account.amount == 0 {
                        self.loadingController?.stopLoading()
                        
                        self.displaySimpleAlertWith(
                            title: "title-error".localized,
                            message: "send-algos-minimum-amount-error-new-account".localized
                        )
                    } else {
                        self.composeAlgosTransactionData(for: selectedAccount)
                    }
                }
            }
            return
        } else {
            loadingController?.startLoadingWithMessage("title-loading".localized)
            composeAlgosTransactionData(for: selectedAccount)
        }
    }
    
    private func composeAlgosTransactionData(for selectedAccount: Account) {
        guard let account = getReceiverAccount() else {
            return
        }
        
        let transactionDraft = AlgosTransactionSendDraft(
            from: selectedAccount,
            toAccount: account.address,
            amount: amount,
            fee: nil,
            isMaxTransaction: isMaxTransaction,
            identifier: nil,
            note: getNoteText()
        )
        
        transactionController.setTransactionDraft(transactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .algosTransaction)
        
        if selectedAccount.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}
