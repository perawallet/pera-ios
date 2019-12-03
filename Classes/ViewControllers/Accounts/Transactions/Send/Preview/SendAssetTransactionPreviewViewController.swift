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

class SendAssetTransactionPreviewViewController: SendTransactionPreviewViewController {
    
    private var assetDetail: AssetDetail
    
    init(
        account: Account,
        receiver: AlgosReceiverState,
        assetDetail: AssetDetail,
        configuration: ViewControllerConfiguration
    ) {
        self.assetDetail = assetDetail
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
        open(.sendTransaction(algosTransaction: nil, assetTransaction: transactionDraft, receiver: receiver), by: .push)
    }
    
    override func displayTransactionPreview() {
        switch receiver {
        case .initial:
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
        case let .contact(contact):
            if let address = contact.address {
                api?.fetchAccount(with: AccountFetchDraft(publicKey: address)) { fetchAccountResponse in
                    switch fetchAccountResponse {
                    case let .success(contactAccount):
                        if contactAccount.isThereAnyDifferentAsset() {
                            if let assets = contactAccount.assets {
                                guard let assetIndex = self.assetDetail.index else {
                                    return
                                }
                                
                                if assets.contains(where: { index, _ -> Bool in
                                    assetIndex == index
                                }) {
                                    self.validateTransaction()
                                } else {
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
                            }
                        }
                    case .failure:
                        break
                    }
                }
            }
        default:
            if !sendTransactionPreviewView.transactionReceiverView.passphraseInputView.inputTextView.text.isEmpty {
                receiver = .address(
                    address: sendTransactionPreviewView.transactionReceiverView.passphraseInputView.inputTextView.text,
                    amount: nil
                )
                
                validateTransaction()
                return
            }
        }
    }
}

extension SendAssetTransactionPreviewViewController {
    private func validateTransaction() {
        if let amountText = sendTransactionPreviewView.amountInputView.inputTextField.text,
            let doubleValue = amountText.doubleForSendSeparator {
            amount = doubleValue
        }
            
        if !isTransactionValid() {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        guard let assetIndex = assetDetail.index,
            let asset = selectedAccount.assets?[assetIndex] else {
                return
        }
        
        if Double(asset.amount) < amount {
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
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.isHidden = true
        sendTransactionPreviewView.amountInputView.algosImageView.isHidden = true
        
        guard let assetName = assetDetail.assetName,
            let assetCode = assetDetail.unitName,
            let assetIndex = assetDetail.index,
            let asset = selectedAccount.assets?[assetIndex] else {
            return
        }
        
        sendTransactionPreviewView.transactionParticipantView.accountSelectionView.detailLabel.text = selectedAccount.name
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.amountLabel.text
            = Double(asset.amount).toDecimalStringForLabel
        title = "balance-send-title".localized + " \(assetName)"
        let nameText = assetName.attributed()
        let codeText = "(\(assetCode))".attributed([.textColor(SharedColors.purple)])
        sendTransactionPreviewView.transactionParticipantView.assetSelectionView.detailLabel.attributedText = nameText + codeText
        
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
