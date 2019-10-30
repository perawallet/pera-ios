//
//  TransactionDetailViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum TransactionType {
    case sent
    case received
}

class TransactionDetailViewController: BaseScrollViewController {
    
    // MARK: Components
    
    private lazy var transactionDetailView: TransactionDetailView = {
        let view = TransactionDetailView(transactionType: transactionType)
        return view
    }()
    
    private var transaction: Transaction
    private let account: Account
    private let transactionType: TransactionType
    private var pollingOperation: PollingOperation?
    
    private let viewModel = TransactionDetailViewModel()
    
    // MARK: Initialization
    
    init(account: Account, transaction: Transaction, transactionType: TransactionType, configuration: ViewControllerConfiguration) {
        self.account = account
        self.transaction = transaction
        self.transactionType = transactionType
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startPolling()
    }
    
    private func startPolling() {
        pollingOperation = PollingOperation(interval: 1.0) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.fetchTransactionDetail()
        }
        
        if transaction.isPending() {
            pollingOperation?.start()
        }
    }
    
    private func fetchTransactionDetail() {
        if !transaction.isPending() {
            return
        }
        
        api?.fetchTransactionDetail(for: account, with: transaction.id) { response in
            switch response {
            case let .success(transaction):
                if !transaction.isPending() {
                    self.transaction.status = .completed
                    self.configureTransactionDetail()
                    self.pollingOperation?.invalidate()
                }
            case .failure:
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pollingOperation?.invalidate()
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        transactionDetailView.delegate = self
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: Notification.Name.ContactAddition,
            object: nil
        )
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "transaction-detail-title".localized
        configureTransactionDetail()
    }
    
    private func configureTransactionDetail() {
        if transactionType == .sent {
            viewModel.configureSentTransaction(transactionDetailView, with: transaction, for: account)
        } else {
            viewModel.configureReceivedTransaction(transactionDetailView, with: transaction, for: account)
        }
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
    
    @objc
    fileprivate func didContactAdded(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Contact],
            let contact = userInfo["contact"] else {
                return
        }
        
        transaction.contact = contact
        
        transactionDetailView.transactionOpponentView.state = .contact(contact)
        transactionDetailView.transactionOpponentView.actionMode = .qrView
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
    
    func transactionDetailViewDidTapShowQRButton(_ transactionDetailView: TransactionDetailView) {
        guard let contact = transaction.contact else {
            return
        }
        
        open(.contactQRDisplay(contact: contact), by: .presentWithoutNavigationController)
    }
}
