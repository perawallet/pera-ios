//
//  TransactionDetailViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionDetailViewController: BaseScrollViewController {
    
    // MARK: Components
    
    private lazy var transactionDetailView: TransactionDetailView = {
        let view = TransactionDetailView()
        return view
    }()
    
    private let transaction: Transaction
    
    private let viewModel = TransactionDetailViewModel()
    
    // MARK: Initialization
    
    init(transaction: Transaction, configuration: ViewControllerConfiguration) {
        self.transaction = transaction
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        transactionDetailView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "transaction-detail-title".localized
        
        viewModel.configure(transactionDetailView, with: transaction)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupTransactionDetailViewLayout()
    }
    
    private func setupTransactionDetailViewLayout() {
        contentView.addSubview(transactionDetailView)
        
        transactionDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: TransactionDetailViewDelegate

extension TransactionDetailViewController: TransactionDetailViewDelegate {
    
    func transactionDetailViewDidTapAddContactButton(_ transactionDetailView: TransactionDetailView) {
        guard let address = transactionDetailView.transactionOpponentView.passphraseInputView.inputTextView.text else {
            return
        }
        
        let viewController = open(.addContact(mode: .new), by: .push) as? AddContactViewController
        
        viewController?.addContactView.userInformationView.algorandAddressInputView.value = address
    }
}
