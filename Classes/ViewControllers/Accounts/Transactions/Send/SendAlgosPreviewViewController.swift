//
//  SendAlgosPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol SendAlgosPreviewViewControllerDelegate: class {
    
    func sendAlgosPreviewViewControllerDidTapSendMoreButton(_ sendAlgosPreviewViewController: SendAlgosPreviewViewController)
}

class SendAlgosPreviewViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var sendAlgosPreviewView: SendAlgosPreviewView = {
        let view = SendAlgosPreviewView()
        return view
    }()
    
    private var transaction: TransactionPreviewDraft
    
    private let receiver: AlgosReceiverState
    
    weak var delegate: SendAlgosPreviewViewControllerDelegate?
    
    var transactionParams: TransactionParams?
    
    // MARK: Initialization
    
    init(transaction: TransactionPreviewDraft, receiver: AlgosReceiverState, configuration: ViewControllerConfiguration) {
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
        sendAlgosPreviewView.accountSelectionView.inputTextField.text = transaction.fromAccount.name
        sendAlgosPreviewView.transactionReceiverView.state = receiver
        
        self.updateFeeLayout()
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        api?.getTransactionParams { response in
            switch response {
            case let .failure(error):
                print(error)
                
            case let .success(params):
                self.transactionParams = params
                self.transaction.fee = params.fee
                
                self.updateFeeLayout()
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    override func linkInteractors() {
        sendAlgosPreviewView.previewViewDelegate = self
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
        if let fee = transaction.fee?.toAlgos, let algos = fee.toDecimalStringForLabel {
            sendAlgosPreviewView.feeInformationView.detailLabel.text = algos
        }
    }
}

// MARK: SendAlgosPreviewViewDelegate

extension SendAlgosPreviewViewController: SendAlgosPreviewViewDelegate {
    
    func sendAlgosPreviewViewDidTapSendButton(_ sendAlgosView: SendAlgosView) {
        if let params = self.transactionParams {
            sendTransaction(with: params)
        } else {
            api?.getTransactionParams { response in
                switch response {
                case let .failure(error):
                    print(error)
                    
                case let .success(params):
                    self.transaction.fee = params.fee
                    self.sendTransaction(with: params)
                }
            }
        }
    }
    
    fileprivate func sendTransaction(with params: TransactionParams) {
        let toAccount: Account
        
        switch receiver {
        case let .address(address):
            toAccount = Account(address: address)
            
        case let .contact(contact):
            guard let address = contact.address else {
                return
            }
            
            toAccount = Account(address: address)
        case .initial:
            return
        }
        
        let transactionDraft = TransactionDraft(
            from: self.transaction.fromAccount,
            to: toAccount,
            amount: Int64(self.transaction.amount.toMicroAlgos),
            transactionParams: params)
        
        self.api?.sendTransaction(with: transactionDraft) { transactionIdResponse in
            switch transactionIdResponse {
            case let .success(transactionId):
                
                self.transaction.identifier = transactionId.identifier
                
                let sendAlgosSuccessViewController = self.open(
                    .sendAlgosSuccess(transaction: self.transaction, receiver: self.receiver),
                    by: .present
                    ) as? SendAlgosSuccessViewController
                
                sendAlgosSuccessViewController?.delegate = self
                
            case let .failure(error):
                
                switch error {
                case let .badRequest(errorData):
                    if let data = errorData,
                        let message = String(data: data, encoding: .utf8) {
                        self.displaySimpleAlertWith(title: "title-error".localized, message: message)
                    }
                    
                default:
                    self.displaySimpleAlertWith(title: "title-error".localized, message: "default-error-message".localized)
                }
            }
        }
    }
}

// MARK: SendAlgosSuccessViewControllerDelegate

extension SendAlgosPreviewViewController: SendAlgosSuccessViewControllerDelegate {
    
    func sendAlgosSuccessViewControllerDidTapDoneButton(_ sendAlgosSuccessViewController: SendAlgosSuccessViewController) {
        navigationController?.popToRootViewController(animated: false)
    }
    
    func sendAlgosSuccessViewControllerDidTapSendMoreButton(_ sendAlgosSuccessViewController: SendAlgosSuccessViewController) {
        closeScreen(by: .pop, animated: false)
        
        delegate?.sendAlgosPreviewViewControllerDidTapSendMoreButton(self)
    }
}
