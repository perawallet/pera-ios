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
    
    init(
        account: Account?,
        receiver: AlgosReceiverState,
        assetDetail: AssetDetail,
        isMaxTransaction: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.assetDetail = assetDetail
        self.isForcedMaxTransaction = isMaxTransaction
        super.init(account: account, receiver: receiver, configuration: configuration)
        self.assetFraction = assetDetail.fractionDecimals
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        configureViewForAsset()
    }
    
    override func presentAccountList(isSender: Bool) {
        let accountListViewController = open(
            .accountList(mode: isSender ? .transactionSender(assetDetail: assetDetail) : .transactionReceiver(assetDetail: assetDetail)),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
    
        accountListViewController?.delegate = self
    }
    
    override func transactionManagerDidComposedAssetTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: AssetTransactionDraft?
    ) {
        guard let transactionDraft = draft else {
            return
        }
        let controller = open(.sendTransaction(algosTransaction: nil, assetTransaction: transactionDraft, receiver: receiver), by: .push)
        (controller as? SendTransactionViewController)?.delegate = self
    }
    
    override func sendTransactionPreviewViewDidTapMaxButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        sendTransactionPreviewView.amountInputView.inputTextField.text
            = selectedAccount?.amount(for: assetDetail)?.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
    }
    
    override func displayTransactionPreview() {
        if selectedAccount == nil {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        switch receiver {
        case let .contact(contact):
            if let address = contact.address {
                checkIfAddressIsValidForTransaction(address)
            }
        case .myAccount:
            validateTransaction()
        default:
            if let address = sendTransactionPreviewView.transactionReceiverView.passphraseInputView.inputTextView.text,
                !address.isEmpty {
                receiver = .address(address: address, amount: nil)
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
        receiver = .address(address: qrAddress, amount: nil)
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
        if let assetAmount = account.amount(for: assetDetail) {
            sendTransactionPreviewView.transactionParticipantView.accountSelectionView.detailLabel.text = account.name
            sendTransactionPreviewView.amountInputView.maxAmount = assetAmount
            
            sendTransactionPreviewView.transactionParticipantView.assetSelectionView.set(
                amount: assetAmount,
                assetFraction: assetDetail.fractionDecimals
            )
            
            if isMaxButtonSelected {
                sendTransactionPreviewView.amountInputView.inputTextField.text =
                    assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
            }
        }
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
                    self.receiver = .address(address: qrAddress, amount: amountText)
                    
                    self.amount = amountValue
                    self.sendTransactionPreviewView.amountInputView.inputTextField.text = amountText
                    return
                }
                
                self.displaySimpleAlertWith(title: "", message: "send-qr-different-asset-alert".localized)
                self.sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: nil)
                self.receiver = .address(address: qrAddress, amount: nil)
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
            let assetId = assetDetail.id else {
            return
        }
        
        transactionManager?.delegate = self
        let transaction = AssetTransactionDraft(
            fromAccount: selectedAccount,
            amount: amount,
            assetIndex: assetId,
            assetDecimalFraction: assetDetail.fractionDecimals,
            isVerified: assetDetail.isVerified
        )
        
        guard let account = getAccount(),
            let transactionManager = transactionManager else {
            return
        }
               
        transactionManager.setAssetTransactionDraft(transaction)
        transactionManager.composeAssetTransactionData(for: account)
    }
}

extension SendAssetTransactionPreviewViewController {
    private func configureViewForAsset() {
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.amountLabel.textColor = SharedColors.black
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.removeFromSuperview()
        sendTransactionPreviewView.amountInputView.algosImageView.removeFromSuperview()
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = !assetDetail.isVerified
        
        if let selectedAccount = selectedAccount,
            let assetAmount = selectedAccount.amount(for: assetDetail) {
            sendTransactionPreviewView.transactionParticipantView.accountSelectionView.detailLabel.text = selectedAccount.name
            sendTransactionPreviewView.amountInputView.maxAmount = assetAmount
            
            sendTransactionPreviewView.transactionParticipantView.assetSelectionView.set(
                amount: assetAmount,
                assetFraction: assetDetail.fractionDecimals
            )
        }
        
        if isForcedMaxTransaction {
            sendTransactionPreviewView.amountInputView.algosImageView.removeFromSuperview()
            sendTransactionPreviewView.amountInputView.inputTextField.text
                = selectedAccount?.amount(for: assetDetail)?.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
            sendTransactionPreviewView.amountInputView.set(enabled: false)
        }
        
        title = "title-send-lowercased".localized + " \(assetDetail.getDisplayNames().0)"
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
        
        switch receiver {
        case .initial:
            amount = 0.00
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case let .address(_, amount):
            if let sendAmount = amount,
                let amountValue = Double(sendAmount) {
                self.amount = amountValue
                sendTransactionPreviewView.amountInputView.inputTextField.text
                    = self.amount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
            }
            
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case .myAccount:
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case .contact:
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        }
    }
}

extension SendAssetTransactionPreviewViewController: SendTransactionViewControllerDelegate {
    func sendTransactionViewController(_ viewController: SendTransactionViewController, didCompleteTransactionFor asset: Int64?) {
        delegate?.sendAssetTransactionPreviewViewController(self, didCompleteTransactionFor: assetDetail)
    }
}
