//
//  TransactionHistoryHeaderSupplementaryView.swift

import UIKit

class TransactionHistoryHeaderSupplementaryView: BaseSupplementaryView<TransactionHistoryHeaderView> {
    
    weak var delegate: TransactionHistoryHeaderSupplementaryViewDelegate?
    
    override func linkInteractors() {
        contextView.delegate = self
    }

    func bind(_ viewModel: TransactionHistoryHeaderViewModel) {
        contextView.bind(viewModel)
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
