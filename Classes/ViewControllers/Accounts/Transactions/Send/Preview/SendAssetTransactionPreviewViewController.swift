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
        account: Account,
        receiver: AlgosReceiverState,
        assetDetail: AssetDetail,
        isMaxTransaction: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.assetDetail = assetDetail
        self.isForcedMaxTransaction = isMaxTransaction
        super.init(account: account, receiver: receiver, configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        configureViewForAsset()
    }
    
    override func presentAccountList() {
        let accountListViewController = open(
            .accountList(mode: .amount(assetDetail: assetDetail)),
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
            = selectedAccount.amount(for: assetDetail)?.toDecimalStringForLabel
    }
    
    override func displayTransactionPreview() {
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
}

extension SendAssetTransactionPreviewViewController {
    private func checkIfAddressIsValidForTransaction(_ address: String) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        api?.fetchAccount(with: AccountFetchDraft(publicKey: address)) { fetchAccountResponse in
            switch fetchAccountResponse {
            case let .success(receiverAccount):
                SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
                SVProgressHUD.dismiss()
                if let assets = receiverAccount.assets {
                    guard let assetIndex = self.assetDetail.index else {
                        return
                    }
                    
                    if assets.contains(where: { index, _ -> Bool in
                        assetIndex == index
                    }) {
                        self.validateTransaction()
                    } else {
                        self.presentAssetNotSupportedAlert()
                    }
                } else {
                    self.presentAssetNotSupportedAlert()
                }
            case .failure:
                SVProgressHUD.showError(withStatus: nil)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func presentAssetNotSupportedAlert() {
        let assetAlertDraft = AssetAlertDraft(
            account: self.selectedAccount,
            assetDetail: self.assetDetail,
            title: "asset-support-title".localized,
            detail: "asset-support-error".localized,
            actionTitle: "title-ok".localized
        )
        
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
            let doubleValue = amountText.doubleForSendSeparator {
            amount = doubleValue
        }
            
        if !isTransactionValid() {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        guard let assetAmount = selectedAccount.amount(for: assetDetail) else {
            return
        }
        
        if assetAmount < amount {
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-asset-amount-error".localized)
            return
        }
        
        composeTransactionData()
    }
    
    private func composeTransactionData() {
        guard let assetIndex = assetDetail.index,
            let index = Int64(assetIndex) else {
            return
        }
        
        transactionManager?.delegate = self
        let transaction = AssetTransactionDraft(
            fromAccount: selectedAccount,
            amount: amount,
            assetIndex: index
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
        
        guard let assetName = assetDetail.assetName,
            let assetAmount = selectedAccount.amount(for: assetDetail) else {
            return
        }
        
        sendTransactionPreviewView.amountInputView.maxAmount = assetAmount
        
        if isForcedMaxTransaction {
            sendTransactionPreviewView.amountInputView.algosImageView.removeFromSuperview()
            sendTransactionPreviewView.amountInputView.inputTextField.text
                = selectedAccount.amount(for: assetDetail)?.toDecimalStringForLabel
            sendTransactionPreviewView.amountInputView.set(enabled: false)
        }
        
        sendTransactionPreviewView.transactionParticipantView.accountSelectionView.detailLabel.text = selectedAccount.name
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.amountLabel.text
            = assetAmount.toDecimalStringForLabel
        title = "balance-send-title".localized + " \(assetName)"
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
        
        switch receiver {
        case .initial:
            amount = 0.00
            sendTransactionPreviewView.transactionReceiverView.state = receiver
        case let .address(_, amount):
            if let sendAmount = amount,
                let amountValue = Double(sendAmount) {
                self.amount = amountValue
                sendTransactionPreviewView.amountInputView.inputTextField.text = self.amount.toDecimalStringForLabel
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
