//
//  SendAlgosTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

class SendAlgosTransactionPreviewViewController: SendTransactionPreviewViewController, TestNetTitleDisplayable {
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 422.0))
    )
    
    private let viewModel: SendAlgosTransactionPreviewViewModel
    
    override var filterOption: SelectAssetViewController.FilterOption {
        return .algos
    }
    
    override init(
        account: Account?,
        assetReceiverState: AssetReceiverState,
        isSenderEditable: Bool,
        configuration: ViewControllerConfiguration
    ) {
        viewModel = SendAlgosTransactionPreviewViewModel(isAccountSelectionEnabled: isSenderEditable)
        super.init(
            account: account,
            assetReceiverState: assetReceiverState,
            isSenderEditable: isSenderEditable,
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
            ledgerApprovalViewController?.dismissScreen()
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
        
        if let handler = completionHandler {
            handler()
        }
    }
    
    override func updateSelectedAccountForSender(_ account: Account) {
        viewModel.update(sendTransactionPreviewView, with: account, isMaxTransaction: isMaxTransaction)
    }
    
    private func displayQRAlert(for amountFromQR: Int64, with asset: Int64?) {
        let configurator = BottomInformationBundle(
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
            .bottomInformation(mode: .qr, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
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
        
        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel)
        
        let proceedAction = UIAlertAction(title: "title-proceed".localized, style: .destructive) { _ in
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
                NotificationBanner.showError("title-error".localized, message: "send-algos-receiver-address-validation".localized)
                return
            }
            
            let receiverFetchDraft = AccountFetchDraft(publicKey: receiverAddress)
                   
            SVProgressHUD.show(withStatus: "title-loading".localized)
            self.api?.fetchAccount(with: receiverFetchDraft) { accountResponse in
                if selectedAccount.type != .ledger {
                    self.dismissProgressIfNeeded()
                }
                
                switch accountResponse {
                case let .failure(_, indexerError):
                    if indexerError?.containsAccount(receiverAddress) ?? false {
                        self.dismissProgressIfNeeded()
                        self.displaySimpleAlertWith(
                            title: "title-error".localized,
                            message: "send-algos-minimum-amount-error-new-account".localized
                        )
                    } else {
                        self.dismissProgressIfNeeded()
                        self.displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
                    }
                case let .success(accountWrapper):
                    if accountWrapper.account.amount == 0 {
                        self.dismissProgressIfNeeded()
                        
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
            SVProgressHUD.show(withStatus: "title-loading".localized)
            composeAlgosTransactionData(for: selectedAccount)
        }
    }
    
    private func composeAlgosTransactionData(for selectedAccount: Account) {
        guard let account = getReceiverAccount() else {
            return
        }
        
        validateTimer()
        
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
    }
}
