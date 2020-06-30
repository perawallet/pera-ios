//
//  TransactionHistoryHeaderSupplementaryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionHistoryHeaderSupplementaryView: BaseSupplementaryView<TransactionHistoryHeaderView> {
    
    weak var delegate: TransactionHistoryHeaderSupplementaryViewDelegate?
    
    override func linkInteractors() {
        contextView.delegate = self
    }
}

extension TransactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderViewDelegate {
    func transactionHistoryHeaderViewDidOpenFilterOptions(_ transactionHistoryHeaderView: TransactionHistoryHeaderView) {
        delegate?.transactionHistoryHeaderSupplementaryViewDidOpenFilterOptions(self)
    }
    
    func transactionHistoryHeaderViewDidShareHistory(_ transactionHistoryHeaderView: TransactionHistoryHeaderView) {
        delegate?.transactionHistoryHeaderSupplementaryViewDidShareHistory(self)
    }
}

protocol TransactionHistoryHeaderSupplementaryViewDelegate: class {
    func transactionHistoryHeaderSupplementaryViewDidOpenFilterOptions(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderSupplementaryView
    )
    func transactionHistoryHeaderSupplementaryViewDidShareHistory(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderSupplementaryView
    )
}
