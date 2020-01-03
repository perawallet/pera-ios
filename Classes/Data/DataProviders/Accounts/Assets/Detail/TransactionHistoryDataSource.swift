//
//  AccountTransactionHistoryDataSource.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Magpie

class TransactionHistoryDataSource: NSObject, UICollectionViewDataSource {
    
    private var transactions = [TransactionItem]()
    private var account: Account
    private var assetDetail: AssetDetail?
    private var contacts = [Contact]()
    
    private let viewModel: AssetDetailViewModel
    private let api: API?
    
    private var transactionParams: TransactionParams?
    private var fetchRequest: EndpointOperatable?
    
    init(api: API?, account: Account, assetDetail: AssetDetail?) {
        self.api = api
        self.account = account
        self.assetDetail = assetDetail
        viewModel = AssetDetailViewModel(account: account, assetDetail: assetDetail)
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < transactions.count {
            if let reward = transactions[indexPath.item] as? Reward {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RewardCell.reusableIdentifier,
                    for: indexPath) as? RewardCell else {
                        fatalError("Index path is out of bounds")
                }
                
                viewModel.configure(cell, with: reward)
                return cell
            } else if let transaction = transactions[indexPath.item] as? Transaction {
                if let transactionStatus = transaction.status {
                    switch transactionStatus {
                    case .completed:
                        return dequeueHistoryCell(in: collectionView, with: transaction, at: indexPath)
                    case .pending:
                        return dequeuePendingCell(in: collectionView, with: transaction, at: indexPath)
                    case .failed:
                        fatalError("Index path is out of bounds")
                    }
                } else {
                    return dequeueHistoryCell(in: collectionView, with: transaction, at: indexPath)
                }
            }
        }
        fatalError("Index path is out of bounds")
    }
}

extension TransactionHistoryDataSource {
    private func dequeueHistoryCell(
        in collectionView: UICollectionView,
        with transaction: Transaction,
        at indexPath: IndexPath
    ) -> TransactionHistoryCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TransactionHistoryCell.reusableIdentifier,
            for: indexPath) as? TransactionHistoryCell else {
                fatalError("Index path is out of bounds")
        }
        
        if let assetTransaction = transaction.assetTransfer {
            if assetTransaction.receiverAddress == viewModel.account.address {
                configure(cell, with: transaction, for: transaction.from)
            } else {
                configure(cell, with: transaction, for: assetTransaction.receiverAddress)
            }
        } else if let payment = transaction.payment {
            if payment.toAddress == viewModel.account.address {
                configure(cell, with: transaction, for: transaction.from)
            } else {
                configure(cell, with: transaction, for: transaction.payment?.toAddress)
            }
        }
        
        return cell
    }
    
    private func configure(_ cell: TransactionHistoryCell, with transaction: Transaction, for address: String?) {
        if let contact = contacts.first(where: { contact -> Bool in
            contact.address == address
        }) {
            transaction.contact = contact
            viewModel.configure(cell.contextView, with: transaction, for: contact)
        } else {
            viewModel.configure(cell.contextView, with: transaction)
        }
    }
    
    private func dequeuePendingCell(
        in collectionView: UICollectionView,
        with transaction: Transaction,
        at indexPath: IndexPath
    ) -> PendingTransactionCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PendingTransactionCell.reusableIdentifier,
            for: indexPath) as? PendingTransactionCell else {
                fatalError("Index path is out of bounds")
        }
        
        if let payment = transaction.payment {
            if payment.toAddress == viewModel.account.address {
                configure(cell, with: transaction, for: transaction.from)
            } else {
                configure(cell, with: transaction, for: transaction.payment?.toAddress)
            }
        } else if let assetTransaction = transaction.assetTransfer {
            if assetTransaction.receiverAddress == viewModel.account.address {
                configure(cell, with: transaction, for: transaction.from)
            } else {
                configure(cell, with: transaction, for: assetTransaction.receiverAddress)
            }
        }
        
        return cell
    }
    
    private func configure(_ cell: PendingTransactionCell, with transaction: Transaction, for address: String?) {
        if let contact = contacts.first(where: { contact -> Bool in
            contact.address == address
        }) {
            transaction.contact = contact
            viewModel.configure(cell.contextView, with: transaction, for: contact)
        } else {
            viewModel.configure(cell.contextView, with: transaction)
        }
    }
}

extension TransactionHistoryDataSource {
    func loadData(
        for account: Account,
        withRefresh refresh: Bool,
        between dates: (Date, Date)? = nil,
        then handler: @escaping ([Transaction]?, Error?) -> Void
    ) {
        api?.getTransactionParams { response in
            switch response {
            case let .failure(error):
                handler(nil, error)
            case let .success(params):
                self.transactionParams = params
                self.viewModel.lastRound = params.lastRound
                
                if let dateRange = dates {
                    self.fetchTransactions(for: account, between: dateRange, withRefresh: refresh, then: handler)
                    return
                }
                
                self.fetchTransactions(for: account, withRefresh: refresh, then: handler)
            }
        }
    }
}

extension TransactionHistoryDataSource {
    private func fetchTransactions(
        for account: Account,
        between dates: (Date, Date),
        withRefresh refresh: Bool,
        then handler: @escaping ([Transaction]?, Error?) -> Void
    ) {
        if refresh {
            transactions.removeAll()
        }
        
        fetchRequest = api?.fetchTransactions(between: dates, for: account) { response in
            switch response {
            case let .failure(error):
                handler(nil, error)
            case let .success(transactions):
                transactions.transactions.forEach { transaction in
                    transaction.status = .completed
                }
                
                if let rewardDisplayPreference = self.api?.session.rewardDisplayPreference,
                    rewardDisplayPreference == .allowed,
                    self.assetDetail == nil {
                    self.setRewards(from: transactions, for: account)
                } else {
                    self.transactions = transactions.transactions.filter { transaction -> Bool in
                        if let assetDetail = self.assetDetail {
                            guard let assetId = transaction.assetTransfer?.assetId else {
                                return false
                            }
                            return "\(assetId)" == assetDetail.index
                        } else {
                            if let assetTransfer = transaction.assetTransfer,
                                assetTransfer.receiverAddress == account.address,
                                assetTransfer.amount == 0 {
                                return true
                            }
                            return transaction.payment != nil
                        }
                    }
                }
                
                handler(transactions.transactions, nil)
            }
        }
    }
}

extension TransactionHistoryDataSource {
    private func fetchTransactions(
        for account: Account,
        withRefresh refresh: Bool,
        then handler: @escaping ([Transaction]?, Error?) -> Void
    ) {
        if refresh {
            transactions.removeAll()
        }
        
        fetchRequest = api?.fetchTransactions(between: nil, for: account, max: 15) { response in
            switch response {
            case let .failure(error):
                handler(nil, error)
            case let .success(transactions):
                transactions.transactions.forEach { transaction in
                    transaction.status = .completed
                }
                
                if let rewardDisplayPreference = self.api?.session.rewardDisplayPreference,
                    rewardDisplayPreference == .allowed,
                    self.assetDetail == nil {
                    self.setRewards(from: transactions, for: account)
                } else {
                    self.transactions = transactions.transactions.filter { transaction -> Bool in
                        if let assetDetail = self.assetDetail {
                            guard let assetId = transaction.assetTransfer?.assetId else {
                                return false
                            }
                            return "\(assetId)" == assetDetail.index
                        } else {
                            if let assetTransfer = transaction.assetTransfer,
                                assetTransfer.receiverAddress == account.address,
                                assetTransfer.amount == 0 {
                                return true
                            }
                            return transaction.payment != nil
                        }
                    }
                }
                
                handler(transactions.transactions, nil)
            }
        }
    }
    
    private func setRewards(from transactions: TransactionList, for account: Account) {
        let filteredTransactions = transactions.transactions.filter { transaction -> Bool in
            if let assetTransfer = transaction.assetTransfer,
                assetTransfer.receiverAddress == account.address,
                assetTransfer.amount == 0 {
                return true
            }
            return transaction.payment != nil && assetDetail == nil
        }
        
        for transaction in filteredTransactions {
            self.transactions.append(transaction)
            if let payment = transaction.payment,
                payment.toAddress == account.address,
                assetDetail == nil {
                if let rewards = transaction.payment?.rewards, rewards > 0 {
                    let reward = Reward(amount: Int64(rewards))
                    self.transactions.append(reward)
                }
            } else {
                if let rewards = transaction.fromRewards,
                    rewards > 0,
                    assetDetail == nil {
                    let reward = Reward(amount: Int64(rewards))
                    self.transactions.append(reward)
                }
            }
        }
    }
}

extension TransactionHistoryDataSource {
    func fetchPendingTransactions(for account: Account, then handler: @escaping ([Transaction]?, Error?) -> Void) {
        api?.fetchPendingTransactions(for: account.address) { response in
            switch response {
            case let .success(pendingTransactionList):
                guard let pendingTransactions = pendingTransactionList.pendingTransactions.transactions else {
                    return
                }
                
                self.filter(pendingTransactions)
                handler(pendingTransactionList.pendingTransactions.transactions, nil)
            case let .failure(error):
                handler(nil, error)
            }
        }
    }
    
    private func filter(_ pendingTransactions: [Transaction]) {
        let filteredTransactions = transactions.filter { ($0 as? Transaction)?.status == .pending }
        if filteredTransactions.count == pendingTransactions.count {
            return
        }
        
        pendingTransactions.forEach { transaction in
            transaction.status = .pending
        }
        self.transactions = self.transactions.filter { item -> Bool in
            guard let transactionItem = item as? Transaction,
                transactionItem.status == .pending else {
                return true
            }
            
            var containsPendingTransaction = false
            
            pendingTransactions.forEach { pendingTransaction in
                containsPendingTransaction = transactionItem.id.identifier == pendingTransaction.id.identifier
            }
            
            return !containsPendingTransaction
        }
        self.transactions.insert(contentsOf: pendingTransactions, at: 0)
    }
}

extension TransactionHistoryDataSource {
    func setupContacts() {
        contacts.removeAll()
        fetchContacts()
    }
    
    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }
                
                self.contacts.append(contentsOf: results)
            default:
                break
            }
        }
    }
    
    func transactionCount() -> Int {
        return transactions.count
    }
    
    func transaction(at indexPath: IndexPath) -> Transaction? {
        if indexPath.item >= 0 && indexPath.item < transactions.count {
            guard let transaction = transactions[indexPath.item] as? Transaction else {
                return nil
            }
            return transaction
        }
        
        return nil
    }
    
    func clear() {
        fetchRequest?.cancel()
        transactions.removeAll()
    }
}
