//
//  SendAlgosSuccessViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SendAlgosSuccessViewControllerDelegate: class {
    
    func sendAlgosSuccessViewControllerDidTapDoneButton(_ sendAlgosSuccessViewController: SendAlgosSuccessViewController)
    func sendAlgosSuccessViewControllerDidTapSendMoreButton(_ sendAlgosSuccessViewController: SendAlgosSuccessViewController)
}

class SendAlgosSuccessViewController: BaseScrollViewController {

    // MARK: Components
    
    private lazy var sendAlgosSuccessView: SendAlgosSuccessView = {
        let view = SendAlgosSuccessView()
        return view
    }()
    
    weak var delegate: SendAlgosSuccessViewControllerDelegate?
    
    private let transaction: Transaction
    
    private let receiver: AlgosReceiverState
    
    // MARK: Initialization
    
    init(transaction: Transaction, receiver: AlgosReceiverState, configuration: ViewControllerConfiguration) {
        self.transaction = transaction
        self.receiver = receiver
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        sendAlgosSuccessView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        sendAlgosSuccessView.amountView.algosAmountView.mode = .normal(transaction.amount)
        
        // TODO: Display proper fee
        sendAlgosSuccessView.feeView.algosAmountView.mode = .normal(1.24)
        
        sendAlgosSuccessView.accountView.detailLabel.text = transaction.accountName
        sendAlgosSuccessView.transactionReceiverView.state = receiver
        sendAlgosSuccessView.transactionIdView.detailLabel.text = transaction.identifier
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupSendAlgosSuccessViewLayout()
    }
    
    private func setupSendAlgosSuccessViewLayout() {
        contentView.addSubview(sendAlgosSuccessView)
        
        sendAlgosSuccessView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: SendAlgosPreviewViewDelegate

extension SendAlgosSuccessViewController: SendAlgosSuccessViewDelegate {
    
    func sendAlgosSuccessViewDidTapDoneButton(_ sendAlgosSuccessView: SendAlgosSuccessView) {
        dismissScreen()
        
        delegate?.sendAlgosSuccessViewControllerDidTapDoneButton(self)
    }
    
    func sendAlgosSuccessViewDidTapSendMoreButton(_ sendAlgosSuccessView: SendAlgosSuccessView) {
        dismissScreen()
        
        delegate?.sendAlgosSuccessViewControllerDidTapSendMoreButton(self)
    }
    
    func sendAlgosSuccessViewDidTapAddContactButton(_ sendAlgosSuccessView: SendAlgosSuccessView) {
        switch receiver {
        case let .address(address):
            let viewController = open(.addContact(mode: .new), by: .push) as? AddContactViewController
            
            viewController?.addContactView.userInformationView.algorandAddressInputView.value = address
        default:
            break
        }
    }
}
