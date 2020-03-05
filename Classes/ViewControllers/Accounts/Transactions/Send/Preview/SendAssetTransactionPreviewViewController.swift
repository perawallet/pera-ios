//
//  SendAssetTransactionPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

protocol SendAssetTransactionPreviewViewControllerDelegate: class {
    func sendAssetTransactionPreviewViewController(
        _ viewController: SendAssetTransactionPreviewViewController,
        didCompleteTransactionFor assetDetail: AssetDetail
    )
}

class SendAssetTransactionPreviewViewController: SendTransactionPreviewViewController {
    
    weak var delegate: SendAssetTransactionPreviewViewControllerDelegate?
    
    private var assetDetail: AssetDetail
    private var isForcedMaxTransaction = false
    private let viewModel: SendAssetTransactionPreviewViewModel
    
    init(
        account: Account?,
        assetReceiverState: AssetReceiverState,
        assetDetail: AssetDetail,
        isMaxTransaction: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.assetDetail = assetDetail
        self.isForcedMaxTransaction = isMaxTransaction
        viewModel = SendAssetTransactionPreviewViewModel(assetDetail: assetDetail, isForcedMaxTransaction: isMaxTransaction)
        super.init(account: account, assetReceiverState: assetReceiverState, configuration: configuration)
        self.assetFraction = assetDetail.fractionDecimals
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "title-send-lowercased".localized + " \(assetDetail.getDisplayNames().0)"
        viewModel.configure(sendTransactionPreviewView, with: selectedAccount)
        configureTransactionReceiver()
    }
    
    override func presentAccountList(accountSelectionState: AccountSelectionState) {
        let accountListViewController = open(
            .accountList(
                mode: accountSelectionState == .sender ?
                    .transactionSender(assetDetail: assetDetail) :
                    .transactionReceiver(assetDetail: assetDetail)
            ),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
    
        accountListViewController?.delegate = self
    }
    
    override func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        guard let assetTransactionDraft = draft as? AssetTransactionSendDraft else {
            return
        }
        
        let controller = open(
            .sendAssetTransaction(
                assetTransactionSendDraft: assetTransactionDraft,
                receiver: assetReceiverState
            ),
            by: .push
        )
        (controller as? SendTransactionViewController)?.delegate = self
    }
    
    override func sendTransactionPreviewViewDidTapMaxButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        sendTransactionPreviewView.amountInputView.inputTextField.text = selectedAccount?.amountDisplayWithFraction(for: assetDetail)
    }
    
    override func displayTransactionPreview() {
        if selectedAccount == nil {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        switch assetReceiverState {
        case let .contact(contact):
            if let address = contact.address {
                checkIfAddressIsValidForTransaction(address)
            }
        case .myAccount:
            validateTransaction()
        default:
            if let address = sendTransactionPreviewView.transactionReceiverView.passphraseInputView.inputTextView.text,
                !address.isEmpty {
                assetReceiverState = .address(address: address, amount: nil)
                checkIfAddressIsValidForTransaction(address)
                return
            } else {
                displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
            }
        }
    }
    
    override func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        guard let qrAddress = qrText.address else {
            return
        }
        
        sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: nil)
        assetReceiverState = .address(address: qrAddress, amount: nil)
        if let qrAmount = qrText.amount {
            displayQRAlert(for: qrAmount, to: qrAddress, with: qrText.asset)
        }
        
        if let qrAsset = qrText.asset {
            let qrAssetText = "\(qrAsset)"
            
            if !isAccountContainsAsset(qrAssetText) {
                presentAssetNotSupportedAlert(receiverAddress: qrText.address)
                
                if let handler = handler {
                    handler()
                }
                
                return
            }
            
            if let assetDetailId = assetDetail.id,
                qrAssetText != "\(assetDetailId)" {
                displaySimpleAlertWith(title: "asset-support-not-same-title".localized, message: "asset-support-not-same-error".localized)
                
                if let handler = handler {
                    handler()
                }
                
                return
            }
        }
    }
    
    private func isAccountContainsAsset(_ assetIndex: String) -> Bool {
        guard let selectedAccount = selectedAccount,
            let assetId = assetDetail.id else {
            return false
        }
        
        var isAssetAddedToAccount = false
        
        for _ in selectedAccount.assetDetails where "\(assetId)" == assetIndex {
            isAssetAddedToAccount = true
            break
        }
        
        return isAssetAddedToAccount
    }
    
    override func updateSelectedAccountForSender(_ account: Account) {
        viewModel.update(sendTransactionPreviewView, with: account, isMaxTransaction: isMaxTransaction)
    }
    
    private func displayQRAlert(for qrAmount: Int64, to qrAddress: String, with assetId: Int64?) {
        let configurator = AlertViewConfigurator(
            title: "send-qr-scan-alert-title".localized,
            image: img("icon-qr-alert"),
            explanation: "send-qr-scan-alert-message".localized,
            actionTitle: "title-approve".localized) {
                if self.assetDetail.id == assetId {
                    let amountValue = qrAmount.assetAmount(fromFraction: self.assetDetail.fractionDecimals)
                    let amountText = amountValue.toFractionStringForLabel(fraction: self.assetDetail.fractionDecimals)
                    
                    self.sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: amountText)
                    self.assetReceiverState = .address(address: qrAddress, amount: amountText)
                    
                    self.amount = amountValue
                    self.sendTransactionPreviewView.amountInputView.inputTextField.text = amountText
                    return
                }
                
                self.displaySimpleAlertWith(title: "", message: "send-qr-different-asset-alert".localized)
                self.sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: nil)
                self.assetReceiverState = .address(address: qrAddress, amount: nil)
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

extension SendAssetTransactionPreviewViewController {
    private func checkIfAddressIsValidForTransaction(_ address: String) {
        if !AlgorandSDK().isValidAddress(address) {
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
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        api?.fetchAccount(with: AccountFetchDraft(publicKey: address)) { fetchAccountResponse in
            switch fetchAccountResponse {
            case let .success(receiverAccount):
                SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
                SVProgressHUD.dismiss()
                if let assets = receiverAccount.assets {
                    guard let assetId = self.assetDetail.id else {
                        return
                    }
                    
                    if assets.contains(where: { index, _ -> Bool in
                        "\(assetId)" == index
                    }) {
                        self.validateTransaction()
                    } else {
                        self.presentAssetNotSupportedAlert(receiverAddress: address)
                    }
                } else {
                    self.presentAssetNotSupportedAlert(receiverAddress: address)
                }
            case .failure:
                SVProgressHUD.showError(withStatus: nil)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func presentAssetNotSupportedAlert(receiverAddress: String?) {
        guard let currentAssetDetailIndex = assetDetail.id else {
            return
        }
        let assetAlertDraft = AssetAlertDraft(
            account: selectedAccount,
            assetIndex: currentAssetDetailIndex,
            assetDetail: assetDetail,
            title: "asset-support-title".localized,
            detail: "asset-support-error".localized,
            actionTitle: "title-ok".localized
        )
        
        if let receiverAddress = receiverAddress,
            let senderAddress = selectedAccount?.address {
            let draft = AssetSupportDraft(
                sender: senderAddress,
                receiver: receiverAddress,
                assetId: currentAssetDetailIndex
            )
            api?.sendAssetSupportRequest(with: draft)
        }
        
        self.open(
            .assetSupportAlert(assetAlertDraft: assetAlertDraft),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: .crossDissolve,
                transitioningDelegate: nil
            )
        )
    }
    
    private func validateTransaction() {
        if let amountText = sendTransactionPreviewView.amountInputView.inputTextField.text,
            let doubleValue = amountText.doubleForSendSeparator(with: assetDetail.fractionDecimals) {
            amount = doubleValue
        }
            
        if !isTransactionValid() {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        guard let assetAmount = selectedAccount?.amount(for: assetDetail) else {
            return
        }
        
        if assetAmount < amount {
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-asset-amount-error".localized)
            return
        }
        
        composeTransactionData()
    }
    
    private func composeTransactionData() {
        guard let selectedAccount = selectedAccount,
            let assetId = assetDetail.id,
            let toAccount = getReceiverAccount()?.address,
            let transactionController = transactionController else {
            return
        }
        
        transactionController.delegate = self
        let transaction = AssetTransactionSendDraft(
            from: selectedAccount,
            toAccount: toAccount,
            amount: amount,
            assetIndex: assetId,
            assetDecimalFraction: assetDetail.fractionDecimals,
            isVerifiedAsset: assetDetail.isVerified
        )
               
        transactionController.setTransactionDraft(transaction)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetTransaction)
    }
}

extension SendAssetTransactionPreviewViewController {
    private func configureTransactionReceiver() {
        switch assetReceiverState {
        case .initial:
            amount = 0.00
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        case let .address(_, amount):
            if let sendAmount = amount,
                let amountValue = Double(sendAmount) {
                self.amount = amountValue
                sendTransactionPreviewView.amountInputView.inputTextField.text
                    = self.amount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
            }
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        case .myAccount, .contact:
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        }
    }
}

extension SendAssetTransactionPreviewViewController: SendTransactionViewControllerDelegate {
    func sendTransactionViewController(_ viewController: SendTransactionViewController, didCompleteTransactionFor asset: Int64?) {
        delegate?.sendAssetTransactionPreviewViewController(self, didCompleteTransactionFor: assetDetail)
    }
}
