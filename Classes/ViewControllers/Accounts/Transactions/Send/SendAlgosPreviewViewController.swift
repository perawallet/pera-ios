//
//  SendAlgosPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Magpie
import SVProgressHUD
import Crypto

class SendAlgosPreviewViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var sendAlgosPreviewView: SendAlgosPreviewView = {
        let view = SendAlgosPreviewView()
        return view
    }()
    
    private var transaction: TransactionPreviewDraft
    private var transactionManager: TransactionManager
    private let receiver: AlgosReceiverState
    
    var transactionData: Data?
    
    // MARK: Initialization
    
    init(
        transactionManager: TransactionManager,
        transaction: TransactionPreviewDraft,
        receiver: AlgosReceiverState,
        configuration: ViewControllerConfiguration
    ) {
        self.transactionManager = transactionManager
        self.transaction = transaction
        self.receiver = receiver
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "send-algos-title".localized
        
        sendAlgosPreviewView.algosInputView.inputTextField.text = transaction.amount.toDecimalStringForLabel
        sendAlgosPreviewView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        sendAlgosPreviewView.accountSelectionView.set(amount: transaction.fromAccount.amount.toAlgos)
        sendAlgosPreviewView.transactionReceiverView.state = receiver
        
        sendAlgosPreviewView.transactionReceiverView.actionMode = .none
        updateFeeLayout()
    }
    
    override func linkInteractors() {
        sendAlgosPreviewView.previewViewDelegate = self
        transactionManager.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupSendAlgosPreviewViewLayout()
    }
    
    private func setupSendAlgosPreviewViewLayout() {
        view.addSubview(sendAlgosPreviewView)
        
        sendAlgosPreviewView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
    
    fileprivate func updateFeeLayout() {
        if var receivedFee = transaction.fee {
            if receivedFee < Transaction.Constant.minimumFee {
                receivedFee = Transaction.Constant.minimumFee
            }
            
            sendAlgosPreviewView.feeInformationView.algosAmountView.mode = .normal(receivedFee.toAlgos)
        }
    }
}

// MARK: SendAlgosPreviewViewDelegate

extension SendAlgosPreviewViewController: SendAlgosPreviewViewDelegate {
    func sendAlgosPreviewViewDidTapSendButton(_ sendAlgosView: SendAlgosView) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        transactionManager.completeTransaction()
    }
}

extension SendAlgosPreviewViewController: TransactionManagerDelegate {
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
