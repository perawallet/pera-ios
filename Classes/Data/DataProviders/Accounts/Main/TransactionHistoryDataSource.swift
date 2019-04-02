//
//  AccountTransactionHistoryDataSource.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol TransactionHistoryDataSourceDelegate: class {
    
    func transactionHistoryDataSource(_ transactionHistoryDataSource: TransactionHistoryDataSource, didFetch transactions: [Transaction])
}

class TransactionHistoryDataSource: NSObject, UICollectionViewDataSource {
    
    weak var delegate: TransactionHistoryDataSourceDelegate?
    
    private var transactions = [Transaction]()
    
    private let viewModel = AccountsViewModel()
    
    // TODO: Added transacitons for test. Should be removed after SDK integration.
    // TODO: Need to configure doubles for amount after "."
    
    private var amounts: [Double] = [12345, 12456, 312, -12312, 3545, -23523, -6475, 4543, -64754, -3453,
                                     234234, 567, -34634, 234, -345345, 324, -4560, 351, -2134, 12340, -140]
    
    // TODO: Might be renamed to load data after sdk integration?
    
    func setupMockData() {
        for index in 0...20 {
            let transaction = Transaction(
                identifier: "\(index)",
                accountName: "Account name \(index)",
                date: Date(),
                amount: amounts[index],
                title: "This is title \(index)"
            )
            
            transactions.append(transaction)
        }
        
        delegate?.transactionHistoryDataSource(self, didFetch: transactions)
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
