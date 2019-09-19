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
    
    enum Constant {
        static let numberOfSecondsInOneDay = 86400
        static let numberOfRoundsInOneDay = 17280
        static let numberOfRoundsInOneHour = 720
        static let numberOfRoundsInOneMinute = 12
        static let roundCreationOffset = 5
        static let numberOfRoundsInTwoDays: Int64 = 34560
    }
    
    private var transactions = [TransactionItem]()
    
    private var contacts = [Contact]()
    
    private let viewModel = AccountsViewModel()
    
    private let api: API?
    
    private var transactionParams: TransactionParams?
    
    private var fetchRequest: EndpointOperatable?
    
    private var currentPaginationOffset: Int64 = 0
    
    init(api: API?) {
        self.api = api
        
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
                switch transaction.status {
                case .completed:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: TransactionHistoryCell.reusableIdentifier,
                        for: indexPath) as? TransactionHistoryCell else {
                            fatalError("Index path is out of bounds")
                            
                    }
                    
                    guard let payment = transaction.payment else {
                        return cell
                    }
                    
                    if payment.toAddress == viewModel.currentAccount?.address {
                        if let contact = contacts.first(where: { contact -> Bool in
                            contact.address == transaction.from
                        }) {
                            transaction.contact = contact
                            
                            viewModel.configure(cell.contextView, with: transaction, for: contact)
                        } else {
                            viewModel.configure(cell.contextView, with: transaction)
                        }
                    } else {
                        if let contact = contacts.first(where: { contact -> Bool in
                            contact.address == transaction.payment?.toAddress
                        }) {
                            transaction.contact = contact
                            
                            viewModel.configure(cell.contextView, with: transaction, for: contact)
                        } else {
                            viewModel.configure(cell.contextView, with: transaction)
                        }
                    }
                    
                    return cell
                case .pending:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: PendingTransactionCell.reusableIdentifier,
                        for: indexPath) as? PendingTransactionCell else {
                            fatalError("Index path is out of bounds")
                    }
                    
                    guard let payment = transaction.payment else {
                        return cell
                    }
                    
                    if payment.toAddress == viewModel.currentAccount?.address {
                        if let contact = contacts.first(where: { contact -> Bool in
                            contact.address == transaction.from
                        }) {
                            transaction.contact = contact
                            
                            viewModel.configure(cell.contextView, with: transaction, for: contact)
                        } else {
                            viewModel.configure(cell.contextView, with: transaction)
                        }
                    } else {
                        if let contact = contacts.first(where: { contact -> Bool in
                            contact.address == transaction.payment?.toAddress
                        }) {
                            transaction.contact = contact
                            viewModel.configure(cell.contextView, with: transaction, for: contact)
                        } else {
                            viewModel.configure(cell.contextView, with: transaction)
                        }
                    }
                    
                    return cell
                case .failed:
                    fatalError("Index path is out of bounds")
                }
            }
        }
        fatalError("Index path is out of bounds")
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
}

// MARK: API

extension TransactionHistoryDataSource {
    
    func setupContacts() {
        contacts.removeAll()
        
        fetchContacts()
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
        currentPaginationOffset = 0
        fetchRequest?.cancel()
        transactions.removeAll()
    }
    
    func loadData(
        for account: Account,
        withRefresh refresh: Bool,
        between dates: (Date, Date)? = nil,
        then handler: @escaping ([Transaction]?, Error?) -> Void
    ) {
        viewModel.currentAccount = account
        
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
    
    private func fetchTransactions(
        for account: Account,
        between dates: (Date, Date),
        withRefresh refresh: Bool,
        then handler: @escaping ([Transaction]?, Error?) -> Void
    ) {
        if refresh {
            transactions.removeAll()
            currentPaginationOffset = Constant.numberOfRoundsInTwoDays
        } else {
            currentPaginationOffset += Constant.numberOfRoundsInTwoDays
        }
        
       // let firstRound = max(rounds.0, rounds.1 - currentPaginationOffset)
        
        fetchRequest = api?.fetchTransactions(between: dates, for: account) { response in
            switch response {
            case let .failure(error):
                handler(nil, error)
            case let .success(transactions):
                self.transactions = transactions.transactions
                handler(transactions.transactions, nil)
            }
        }
    }
    
    private func calculateRounds(from dates: (Date, Date)) -> (Int64, Int64)? {
        guard let params = transactionParams else {
            return nil
        }
        
        let startDate = dates.0
        let endDate = dates.1
        
        let startDayDifference = -Int(startDate.timeIntervalSinceNow) / Constant.numberOfSecondsInOneDay
        let endDayDifference = -Int(endDate.timeIntervalSinceNow) / Constant.numberOfSecondsInOneDay
        
        // If selected days are today, start round is begining of the day and end in last round
        // If selected end day is today, start from selected day round and end in last round
        // If selected days are equal, start from beginning of the day and end in end of the day.
        
        var firstRound: Int64
        var lastRound: Int64
        
        if endDayDifference == 0 && startDayDifference == 0 {
            firstRound = params.lastRound
                - Int64(startDate.hour * Constant.numberOfRoundsInOneHour)
                - Int64(startDate.minute * Constant.numberOfRoundsInOneMinute)
            lastRound = params.lastRound
        } else if endDayDifference == 0 {
            firstRound = params.lastRound - Int64(startDayDifference * Constant.numberOfRoundsInOneDay)
            lastRound = params.lastRound
        } else if endDayDifference == startDayDifference {
            firstRound = params.lastRound
                - Int64(startDayDifference * Constant.numberOfRoundsInOneDay)
                - Int64(startDate.hour * Constant.numberOfRoundsInOneHour)
            lastRound = params.lastRound
                - Int64(endDayDifference * Constant.numberOfRoundsInOneDay)
                + Int64((24 - endDate.hour) * Constant.numberOfRoundsInOneHour)
        } else {
            firstRound = params.lastRound - Int64(startDayDifference * Constant.numberOfRoundsInOneDay)
            lastRound = params.lastRound - Int64(endDayDifference * Constant.numberOfRoundsInOneDay)
        }
        
        // Check bounds for rounds
        
        if firstRound < 1 {
            firstRound = 1
        }
        
        if lastRound > params.lastRound {
            lastRound = params.lastRound
        }
        
        return (firstRound, lastRound)
    }
    
    private func fetchTransactions(
        for account: Account,
        withRefresh refresh: Bool,
        then handler: @escaping ([Transaction]?, Error?) -> Void
    ) {
        if refresh {
            transactions.removeAll()
            currentPaginationOffset = Constant.numberOfRoundsInTwoDays
        } else {
            currentPaginationOffset += Constant.numberOfRoundsInTwoDays
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
                    rewardDisplayPreference == .allowed {
                    self.setRewards(from: transactions, for: account)
                } else {
                    self.transactions = transactions.transactions
                }
                
                handler(transactions.transactions, nil)
            }
        }
    }
    
    func fetchPendingTransactions(for account: Account, then handler: @escaping ([Transaction]?, Error?) -> Void) {
        api?.fetchPendingTransactions(for: account.address) { response in
            switch response {
            case let .success(pendingTransactionList):
                guard let pendingTransactions = pendingTransactionList.pendingTransactions.transactions else {
                    return
                }
                pendingTransactions.forEach { transaction in
                    transaction.status = .pending
                }
                self.transactions.insert(contentsOf: pendingTransactions, at: 0)
                handler(pendingTransactionList.pendingTransactions.transactions, nil)
            case let .failure(error):
                handler(nil, error)
            }
        }
    }
    
    private func setRewards(from transactions: TransactionList, for account: Account) {
        for transaction in transactions.transactions {
            self.transactions.append(transaction)
            if let payment = transaction.payment,
                payment.toAddress == account.address {
                if let rewards = transaction.payment?.rewards, rewards > 0 {
                    let reward = Reward(amount: Int64(rewards))
                    self.transactions.append(reward)
                }
            } else {
                if let rewards = transaction.fromRewards, rewards > 0 {
                    let reward = Reward(amount: Int64(rewards))
                    self.transactions.append(reward)
                }
            }
        }
    }
}
