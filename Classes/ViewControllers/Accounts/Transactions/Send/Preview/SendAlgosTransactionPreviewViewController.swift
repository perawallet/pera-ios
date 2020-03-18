//
//  SendAlgosTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

class SendAlgosTransactionPreviewViewController: SendTransactionPreviewViewController {
    
    private let viewModel = SendAlgosTransactionPreviewViewModel()
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "send-algos-title".localized
        viewModel.configure(sendTransactionPreviewView, with: selectedAccount)
        configureTransactionReceiver()
    }
    
    override func presentAccountList(accountSelectionState: AccountSelectionState) {
        let accountListViewController = open(
            .accountList(
                mode: accountSelectionState == .sender ? .transactionSender(assetDetail: nil) : .transactionReceiver(assetDetail: nil)
            ),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
    
        accountListViewController?.delegate = self
    }
    
    override func displayTransactionPreview() {
        guard let selectedAccount = selectedAccount else {
            displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        if !sendTransactionPreviewView.transactionReceiverView.passphraseInputView.inputTextView.text.isEmpty {
            switch assetReceiverState {
            case .contact:
                break
            default:
                assetReceiverState = .address(
                    address: sendTransactionPreviewView.transactionReceiverView.passphraseInputView.inputTextView.text,
                    amount: nil
                )
            }
        }
            
        if let algosAmountText = sendTransactionPreviewView.amountInputView.inputTextField.text,
            let doubleValue = algosAmountText.doubleForSendSeparator(with: algosFraction) {
            amount = doubleValue
        }
            
        if !isTransactionValid() {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
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
                presentAccountRemoveWarning()
                return
            } else if selectedAccount.isThereAnyDifferentAsset() {
                displaySimpleAlertWith(title: "send-algos-account-delete-asset-title".localized, message: "")
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
        
        if algosTransactionDraft.from.type == .ledger {
            ledgerApprovalViewController.removeFromParentController()
        }
        
        open(
            .sendAlgosTransaction(
                algosTransactionSendDraft: algosTransactionDraft,
                transactionController: transactionController,
                receiver: assetReceiverState
            ),
            by: .push
        )
    }
    
    override func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        guard let qrAddress = qrText.address else {
            return
        }
        sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: nil)
        if let amountFromQR = qrText.amount {
            displayQRAlert(for: amountFromQR, with: qrText.asset)
        }
        assetReceiverState = .address(address: qrAddress, amount: nil)
        
        if let handler = handler {
            handler()
        }
    }
    
    override func updateSelectedAccountForSender(_ account: Account) {
        viewModel.update(sendTransactionPreviewView, with: account, isMaxTransaction: isMaxTransaction)
    }
    
    private func displayQRAlert(for amountFromQR: Int64, with asset: Int64?) {
        let configurator = AlertViewConfigurator(
            title: "send-qr-scan-alert-title".localized,
            image: img("icon-qr-alert"),
            explanation: "send-qr-scan-alert-message".localized,
            actionTitle: "title-approve".localized) {
                if asset != nil {
                    self.displaySimpleAlertWith(title: "", message: "send-qr-different-asset-alert".localized)
                    return
                }
                let receivedAmount = amountFromQR.toAlgos
                self.amount = receivedAmount
                self.sendTransactionPreviewView.amountInputView.inputTextField.text = receivedAmount.toDecimalStringForAlgosInput
                return
        }
        
        open(
            .alert(mode: .qr, alertConfigurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: .crossDissolve,
                transitioningDelegate: nil
            )
        )
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
                let amountInt = Int(sendAmount) {
                
                self.amount = amountInt.toAlgos
                sendTransactionPreviewView.amountInputView.inputTextField.text = self.amount.toDecimalStringForLabel
            }
            
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        case .myAccount, .contact:
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        }
    }
}

extension SendAlgosTransactionPreviewViewController {
    private func presentAccountRemoveWarning() {
        let alertController = UIAlertController(
            title: "send-algos-account-delete-title".localized,
            message: "send-algos-account-delete-body".localized,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "title-cancel-lowercased".localized, style: .cancel)
        
        let proceedAction = UIAlertAction(title: "title-proceed-lowercased".localized, style: .destructive) { _ in
            self.composeTransactionData()
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
                guard let api = api else {
                    return
                }
                let pushNotificationController = PushNotificationController(api: api)
                pushNotificationController.showFeedbackMessage(
                    "title-error".localized,
                    subtitle: "send-algos-receiver-address-validation".localized
                )
                return
            }
            
            let receiverFetchDraft = AccountFetchDraft(publicKey: receiverAddress)
                   
            SVProgressHUD.show(withStatus: "title-loading".localized)
            self.api?.fetchAccount(with: receiverFetchDraft) { accountResponse in
                SVProgressHUD.dismiss()
                       
                switch accountResponse {
                case let .failure(error):
                    self.displaySimpleAlertWith(title: "title-error".localized, message: error.localizedDescription)
                case let .success(account):
                    if account.amount == 0 {
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
            identifier: nil
        )
        
        transactionController.setTransactionDraft(transactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .algosTransaction)
    }
}
