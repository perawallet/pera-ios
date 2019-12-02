//
//  SendTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Magpie
import SVProgressHUD
import Crypto

class SendTransactionViewController: BaseViewController {
    
    private lazy var sendTransactionView = SendTransactionView()
    
    private var transaction: TransactionPreviewDraft
    private let receiver: AlgosReceiverState
    
    var transactionData: Data?
    
    init(
        transaction: TransactionPreviewDraft,
        receiver: AlgosReceiverState,
        configuration: ViewControllerConfiguration
    ) {
        self.transaction = transaction
        self.receiver = receiver
        
        super.init(configuration: configuration)
        
        self.transactionManager?.setTransactionDraft(transaction)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "send-algos-title".localized
        
        sendTransactionView.algosInputView.inputTextField.text = transaction.amount.toDecimalStringForLabel
        sendTransactionView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        sendTransactionView.accountSelectionView.set(amount: transaction.fromAccount.amount.toAlgos)
        sendTransactionView.transactionReceiverView.state = receiver
        
        sendTransactionView.transactionReceiverView.actionMode = .none
        updateFeeLayout()
    }
    
    override func linkInteractors() {
        sendTransactionView.transactionDelegate = self
        transactionManager?.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSendTransactionViewLayout()
    }
}

extension SendTransactionViewController {
    private func setupSendTransactionViewLayout() {
        view.addSubview(sendTransactionView)
        
        sendTransactionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
    
    fileprivate func updateFeeLayout() {
        if var receivedFee = transaction.fee {
            if receivedFee < Transaction.Constant.minimumFee {
                receivedFee = Transaction.Constant.minimumFee
            }
            
            sendTransactionView.feeInformationView.algosAmountView.mode = .normal(receivedFee.toAlgos)
        }
    }
}

extension SendTransactionViewController: SendTransactionViewDelegate {
    func sendTransactionViewDidTapSendButton(_ sendTransactionView: SendTransactionView) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        transactionManager?.completeTransaction()
    }
}

extension SendTransactionViewController: TransactionManagerDelegate {
    func transactionManager(_ transactionManager: TransactionManager, didCompletedTransaction id: TransactionID) {
        SVProgressHUD.dismiss()
        self.transaction.identifier = id.identifier
        navigationController?.popToRootViewController(animated: false)
    }
    
    func transactionManager(_ transactionManager: TransactionManager, didFailedTransaction error: Error) {
        SVProgressHUD.dismiss()
        
        switch error {
        case .networkUnavailable:
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
        default:
            displaySimpleAlertWith(title: "title-error".localized, message: error.localizedDescription)
        }
    }
}
