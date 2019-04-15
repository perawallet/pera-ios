//
//  AccountTransactionHistoryDataSource.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionHistoryDataSource: NSObject, UICollectionViewDataSource {
    
    enum Constant {
        static let numberOfSecondsInOneDay = 86400
        static let numberOfRoundsInOneDay = 17280
        static let numberOfRoundsInOneHour = 720
        static let numberOfRoundsInOneMinute = 12
        static let roundCreationOffset = 5
    }
    
    private var transactions = [Transaction]()
    
    private let viewModel = AccountsViewModel()
    
    private let api: API?
    
    private var transactionParams: TransactionParams?
    
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TransactionHistoryCell.reusableIdentifier,
            for: indexPath) as? TransactionHistoryCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.item < transactions.count {
            let transaction = transactions[indexPath.row]
            
            viewModel.configure(cell, with: transaction)
        }
        
        return cell
    }
}

// MARK: API

extension TransactionHistoryDataSource {
    
    func loadData(for account: Account, between dates: (Date, Date)? = nil, then handler: @escaping ([Transaction]?, Error?) -> Void) {
        api?.getTransactionParams { response in
            switch response {
            case let .failure(error):
                handler(nil, error)
            case let .success(params):
                self.transactionParams = params
                
                if let dateRange = dates {
                    self.fetchTransactions(for: account, between: dateRange, then: handler)
                    return
                }
                
                self.fetchTransactions(for: account, then: handler)
            }
        }
    }
    
    private func fetchTransactions(
        for account: Account,
        between dates: (Date, Date),
        then handler: @escaping ([Transaction]?, Error?) -> Void
    ) {
        guard let rounds = calculateRounds(from: dates) else {
            return
        }
        
        api?.fetchTransactions(between: (rounds.0, rounds.1), for: account) { response in
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
    
    private func fetchTransactions(for account: Account, then handler: @escaping ([Transaction]?, Error?) -> Void) {
        guard let params = transactionParams else {
            return
        }
        
        let firstRound = max(0, params.lastRound - 34560) // 2 days
        
        api?.fetchTransactions(between: (firstRound, params.lastRound), for: account) { response in
            switch response {
            case let .failure(error):
                handler(nil, error)
            case let .success(transactions):
                self.transactions = transactions.transactions
                handler(transactions.transactions, nil)
            }
        }
    }
}
