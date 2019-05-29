//
//  SendAlgosPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD
import Crypto

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
    
    var transactionData: Data?
    
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
        sendAlgosPreviewView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        sendAlgosPreviewView.accountSelectionView.set(amount: transaction.fromAccount.amount.toAlgos)
        sendAlgosPreviewView.transactionReceiverView.state = receiver
        
        sendAlgosPreviewView.transactionReceiverView.qrButton.setImage(nil, for: .normal)
        sendAlgosPreviewView.transactionReceiverView.receiverContactView.qrDisplayButton.setImage(nil, for: .normal)
        sendAlgosPreviewView.transactionReceiverView.receiverContactView.sendButton.setImage(nil, for: .normal)
        
        self.updateFeeLayout()
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        api?.getTransactionParams { response in
            switch response {
            case let .failure(error):
                print(error)
                
            case let .success(params):
                self.composeTransactionData(with: params)
                self.updateFeeLayout()
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    private func composeTransactionData(with params: TransactionParams) {
        transaction.fee = params.fee
        
        guard let account = getAccount() else {
            return
        }
        
        let firstRound = params.lastRound
        let lastRound = firstRound + 1000
        
        var transactionError: NSError?
        
        guard let transactionData = TransactionMakePaymentTxn(
            transaction.fromAccount.address,
            account.address,
            params.fee,
            Int64(transaction.amount.toMicroAlgos),
            firstRound,
            lastRound,
            nil,
            "",
            "",
            params.genesisHashData,
            &transactionError
        ) else {
            return
        }
        
        var signedTransactionError: NSError?
        
        guard let privateData = session?.privateData(forAccount: transaction.fromAccount.address),
            let signedTransactionData = CryptoSignTransaction(privateData, transactionData, &signedTransactionError) else {
                return
        }
        
        self.transactionData = signedTransactionData
        transaction.fee = Int64(signedTransactionData.count) * params.fee
    }
    
    private func getAccount() -> Account? {
        let account: Account
        
        switch receiver {
        case let .address(address, _):
            account = Account(address: address)
            
        case let .contact(contact):
            guard let address = contact.address else {
                return nil
            }
            
            account = Account(address: address)
        case .initial:
            return nil
        }
        
        return account
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
        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        if let transactionData = self.transactionData {
            sendTransaction(with: transactionData)
        } else {
            api?.getTransactionParams { response in
                switch response {
                case let .failure(error):
                    print(error)
                    
                case let .success(params):
                    self.composeTransactionData(with: params)
                    
                    guard let transactionData = self.transactionData else {
                        return
                    }
                    
                    self.sendTransaction(with: transactionData)
                }
            }
        }
    }
    
    fileprivate func sendTransaction(with transactionData: Data) {
        self.api?.sendTransaction(with: transactionData) { transactionIdResponse in
            switch transactionIdResponse {
            case let .success(transactionId):
                SVProgressHUD.dismiss()
                
                self.transaction.identifier = transactionId.identifier
                
                let sendAlgosSuccessViewController = self.open(
                    .sendAlgosSuccess(transaction: self.transaction, receiver: self.receiver),
                    by: .present
                    ) as? SendAlgosSuccessViewController
                
                sendAlgosSuccessViewController?.delegate = self
                
            case let .failure(error):
                SVProgressHUD.dismiss()
                
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
