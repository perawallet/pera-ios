//
//  SendAlgosPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SendAlgosPreviewViewControllerDelegate: class {
    
    func sendAlgosPreviewViewControllerDidTapSendMoreButton(_ sendAlgosPreviewViewController: SendAlgosPreviewViewController)
}

class SendAlgosPreviewViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var sendAlgosPreviewView: SendAlgosPreviewView = {
        let view = SendAlgosPreviewView()
        return view
    }()
    
    private let transaction: Transaction
    
    private let receiver: AlgosReceiverState
    
    weak var delegate: SendAlgosPreviewViewControllerDelegate?
    
    // MARK: Initialization
    
    init(transaction: Transaction, receiver: AlgosReceiverState, configuration: ViewControllerConfiguration) {
        self.transaction = transaction
        self.receiver = receiver
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "send-algos-title".localized
        
        sendAlgosPreviewView.algosInputView.inputTextField.text = "\(transaction.amount)"
        sendAlgosPreviewView.accountSelectionView.inputTextField.text = transaction.accountName
        sendAlgosPreviewView.transactionReceiverView.state = receiver
        
        // TODO: Display proper fee
        sendAlgosPreviewView.feeInformationView.detailLabel.text = "1.24"
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
}

// MARK: SendAlgosPreviewViewDelegate

extension SendAlgosPreviewViewController: SendAlgosPreviewViewDelegate {
    
    func sendAlgosPreviewViewDidTapSendButton(_ sendAlgosView: SendAlgosView) {
        // TODO: Complete transctions
        
        let sendAlgosSuccessViewController = open(
            .sendAlgosSuccess(transaction: transaction, receiver: receiver),
            by: .present
        ) as? SendAlgosSuccessViewController
        
        sendAlgosSuccessViewController?.delegate = self
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
