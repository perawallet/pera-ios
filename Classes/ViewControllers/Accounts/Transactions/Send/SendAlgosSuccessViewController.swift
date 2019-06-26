//
//  SendAlgosSuccessViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Lottie

protocol SendAlgosSuccessViewControllerDelegate: class {
    
    func sendAlgosSuccessViewControllerDidTapDoneButton(_ sendAlgosSuccessViewController: SendAlgosSuccessViewController)
    func sendAlgosSuccessViewControllerDidTapSendMoreButton(
        _ sendAlgosSuccessViewController: SendAlgosSuccessViewController,
        withReceiver state: AlgosReceiverState
    )
}

class SendAlgosSuccessViewController: BaseScrollViewController {

    // MARK: Components
    
    private lazy var sendAlgosSuccessView: SendAlgosSuccessView = {
        let view = SendAlgosSuccessView()
        return view
    }()
    
    weak var delegate: SendAlgosSuccessViewControllerDelegate?
    
    private let transaction: TransactionPreviewDraft
    
    private let receiver: AlgosReceiverState
    
    // MARK: Initialization
    
    init(transaction: TransactionPreviewDraft, receiver: AlgosReceiverState, configuration: ViewControllerConfiguration) {
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
        
        if var receivedFee = transaction.fee {
            if receivedFee < Transaction.Constant.minimumFee {
                receivedFee = Transaction.Constant.minimumFee
            }
            
            sendAlgosSuccessView.feeView.algosAmountView.mode = .normal(receivedFee.toAlgos)
        }
        
        sendAlgosSuccessView.accountView.detailLabel.text = transaction.fromAccount.name
        sendAlgosSuccessView.transactionReceiverView.state = receiver
        
        switch receiver {
        case .contact:
            sendAlgosSuccessView.transactionReceiverView.actionMode = .none
        default:
            sendAlgosSuccessView.transactionReceiverView.actionMode = .contactAddition
        }
        
        if let identifier = transaction.identifier {
            var formattedId = identifier
            
            if identifier.hasPrefix("tx-") {
                formattedId = String(formattedId.dropFirst(3))
            }
            
            sendAlgosSuccessView.transactionIdView.detailLabel.text = formattedId
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sendAlgosSuccessView.successAnimationView.play(fromProgress: 0, toProgress: 2 / 3, loopMode: .playOnce)
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
        
        delegate?.sendAlgosSuccessViewControllerDidTapSendMoreButton(self, withReceiver: receiver)
    }
    
    func sendAlgosSuccessViewDidTapAddContactButton(_ sendAlgosSuccessView: SendAlgosSuccessView) {
        switch receiver {
        case let .address(address, _):
            let viewController = open(.addContact(mode: .new), by: .push) as? AddContactViewController
            
            viewController?.addContactView.userInformationView.algorandAddressInputView.value = address
        default:
            break
        }
    }
}
