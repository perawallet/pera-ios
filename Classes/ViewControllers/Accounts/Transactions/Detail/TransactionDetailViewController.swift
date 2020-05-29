//
//  TransactionDetailViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionDetailViewController: BaseScrollViewController {
    
    private lazy var transactionDetailView = TransactionDetailView(transactionType: transactionType)
    
    private var transaction: Transaction
    private let account: Account
    private var assetDetail: AssetDetail?
    private let transactionType: TransactionType
    private var pollingOperation: PollingOperation?
    
    private let viewModel = TransactionDetailViewModel()
    
    init(
        account: Account,
        transaction: Transaction,
        transactionType: TransactionType,
        assetDetail: AssetDetail?,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.transaction = transaction
        self.transactionType = transactionType
        self.assetDetail = assetDetail
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPolling()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pollingOperation?.invalidate()
    }
    
    override func linkInteractors() {
        transactionDetailView.delegate = self
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: .ContactAddition,
            object: nil
        )
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "transaction-detail-title".localized
        contentView.backgroundColor = SharedColors.secondaryBackground
        setSecondaryBackgroundColor()
        configureTransactionDetail()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupTransactionDetailViewLayout()
    }
}

extension TransactionDetailViewController {
    @objc
    private func didContactAdded(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Contact],
            let contact = userInfo["contact"] else {
                return
        }
        
        transaction.contact = contact
        viewModel.setOpponent(for: transaction, with: contact.address ?? "", in: transactionDetailView)
    }
}

extension TransactionDetailViewController {
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
                    transaction.contact = self.transaction.contact
                    self.transaction = transaction
                    self.transaction.status = .completed
                    self.configureTransactionDetail()
                    self.pollingOperation?.invalidate()
                }
            case .failure:
                break
            }
        }
    }
}

extension TransactionDetailViewController {
    private func configureTransactionDetail() {
        if transactionType == .sent {
            viewModel.configureSentTransaction(transactionDetailView, with: transaction, and: assetDetail, for: account)
        } else {
            viewModel.configureReceivedTransaction(transactionDetailView, with: transaction, and: assetDetail, for: account)
        }
    }
}

extension TransactionDetailViewController {
    private func setupTransactionDetailViewLayout() {
        contentView.addSubview(transactionDetailView)
        
        transactionDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TransactionDetailViewController: TransactionDetailViewDelegate {
    func transactionDetailViewDidTapOpponentActionButton(_ transactionDetailView: TransactionDetailView) {
        guard let contact = transaction.contact,
            let address = contact.address else {
                guard let address = transactionDetailView.opponentView.contactDisplayView.nameLabel.text else {
                    return
                }

                let viewController = open(.addContact(mode: .new()), by: .push) as? AddContactViewController
                viewController?.addContactView.userInformationView.algorandAddressInputView.value = address
                return
        }
        
        let draft = QRCreationDraft(address: address, mode: .address)
        open(.qrGenerator(title: contact.name, draft: draft), by: .present)
    }
}

enum TransactionType {
    case sent
    case received
}
