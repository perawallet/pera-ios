//
//  SendAlgosTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Crypto
import SVProgressHUD

class SendAlgosTransactionPreviewViewController: SendTransactionPreviewViewController {
    
    override func configureAppearance() {
        super.configureAppearance()
        configureViewForAlgos()
    }
    
    override func presentAccountList(isSender: Bool) {
        let accountListViewController = open(
            .accountList(mode: isSender ? .transactionSender(assetDetail: nil) : .transactionReceiver(assetDetail: nil)),
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
            switch receiver {
            case .contact:
                break
            default:
                receiver = .address(
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
            
        if selectedAccount.amount <= UInt64(amount.toMicroAlgos) && !isMaxButtonSelected {
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-amount-error".localized)
            return
        }
            
        if !isMaxButtonSelected {
            if Int(selectedAccount.amount) - Int(amount.toMicroAlgos) - Int(minimumFee) < minimumTransactionMicroAlgosLimit {
                self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-minimum-amount-error".localized)
                return
            }
        }
            
        if isMaxButtonSelected {
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
    
    override func transactionManagerDidComposedAlgoTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: TransactionPreviewDraft?
    ) {
        guard let transactionDraft = draft else {
            return
        }
        open(.sendTransaction(algosTransaction: transactionDraft, assetTransaction: nil, receiver: receiver), by: .push)
    }
    
    override func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        guard let qrAddress = qrText.address else {
            return
        }
        sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: nil)
        if let amountFromQR = qrText.amount,
            amountFromQR != 0 {
            let receivedAmount = amountFromQR.toAlgos
            amount = receivedAmount
            sendTransactionPreviewView.amountInputView.inputTextField.text = receivedAmount.toDecimalStringForAlgosInput
        }
        
        receiver = .address(address: qrAddress, amount: nil)
        
        if let handler = handler {
            handler()
        }
    }
    
    override func updateSelectedAccountForSender(_ account: Account) {
        sendTransactionPreviewView.transactionParticipantView.accountSelectionView.detailLabel.text = account.name
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.set(amount: account.amount.toAlgos)
        sendTransactionPreviewView.amountInputView.maxAmount = account.amount.toAlgos
        
        if isMaxButtonSelected {
            sendTransactionPreviewView.amountInputView.inputTextField.text =
                sendTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.amountLabel.text
        }
    }
}

extension SendAlgosTransactionPreviewViewController {
    private func configureViewForAlgos() {
        title = "send-algos-title".localized
        
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.amountLabel.textColor =
            SharedColors.turquois
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = false
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.tintColor =
            SharedColors.turquois
        updateSelectedAccountAppearance()
        
        switch receiver {
        case .initial:
            amount = 0.00
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case let .address(_, amount):
            if let sendAmount = amount,
                let amountInt = Int(sendAmount) {
                
                self.amount = amountInt.toAlgos
                sendTransactionPreviewView.amountInputView.inputTextField.text = self.amount.toDecimalStringForLabel
            }
            
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case .myAccount:
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case .contact:
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        }
    }
    
    private func updateSelectedAccountAppearance() {
        guard let selectedAccount = selectedAccount else {
            return
        }
        
        sendTransactionPreviewView.transactionParticipantView.accountSelectionView.detailLabel.text = selectedAccount.name
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.set(amount: selectedAccount.amount.toAlgos)

        sendTransactionPreviewView.amountInputView.maxAmount = selectedAccount.amount.toAlgos
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
        transactionManager?.delegate = self
        guard let selectedAccount = selectedAccount else {
            return
        }
        
        if amount.toMicroAlgos < minimumTransactionMicroAlgosLimit {
            var receiverAddress: String
                   
            switch receiver {
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
            
            if !UtilsIsValidAddress(receiverAddress) {
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
                    if !self.isConnectedToInternet {
                        self.displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
                        return
                    }
                    self.displaySimpleAlertWith(title: "title-error".localized, message: error.localizedDescription)
                case let .success(account):
                    if account.amount == 0 {
                        self.displaySimpleAlertWith(title: "title-error".localized,
                                                    message: "send-algos-minimum-amount-error-new-account".localized)
                    } else {
                        let transaction = TransactionPreviewDraft(
                            fromAccount: selectedAccount,
                            amount: self.amount,
                            identifier: nil,
                            fee: nil,
                            isMaxTransaction: self.isMaxButtonSelected
                        )
                        
                        guard let account = self.getAccount(),
                            let transactionManager = self.transactionManager else {
                            return
                        }
                               
                        transactionManager.setTransactionDraft(transaction)
                        transactionManager.composeAlgoTransactionData(
                            for: account,
                            isMaxValue: self.isMaxButtonSelected
                        )
                    }
                }
            }
            return
        } else {
            let transaction = TransactionPreviewDraft(
                fromAccount: selectedAccount,
                amount: amount,
                identifier: nil,
                fee: nil,
                isMaxTransaction: isMaxButtonSelected
            )
                   
            guard let account = getAccount(),
                let transactionManager = transactionManager else {
                return
            }
                   
            transactionManager.setTransactionDraft(transaction)
            transactionManager.composeAlgoTransactionData(
                for: account,
                isMaxValue: isMaxButtonSelected
            )
        }
    }
}
