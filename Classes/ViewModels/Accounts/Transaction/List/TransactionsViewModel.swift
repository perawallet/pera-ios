//
//  TransactionsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionsViewModel {
    func configure(_ view: TransactionHistoryHeaderSupplementaryView, for filterOption: TransactionFilterViewController.FilterOption) {
        switch filterOption {
        case .allTime:
            view.contextView.setFilterImage(img("icon-transaction-filter"))
            view.contextView.setTitle("contacts-transactions-title".localized)
        case .today:
            view.contextView.setFilterImage(img("icon-transaction-filter-badge"))
            view.contextView.setTitle("transaction-filter-option-today".localized)
        case .yesterday:
            view.contextView.setFilterImage(img("icon-transaction-filter-badge"))
            view.contextView.setTitle("transaction-filter-option-yesterday".localized)
        case .lastWeek:
            view.contextView.setFilterImage(img("icon-transaction-filter-badge"))
            view.contextView.setTitle("transaction-filter-option-week".localized)
        case .lastMonth:
            view.contextView.setFilterImage(img("icon-transaction-filter-badge"))
            view.contextView.setTitle("transaction-filter-option-month".localized)
        case let .customRange(from, to):
            view.contextView.setFilterImage(img("icon-transaction-filter-badge"))
            
            if let from = from,
                let to = to {
                if from.year == to.year {
                    view.contextView.setTitle("\(from.toFormat("MMM dd"))-\(to.toFormat("MMM dd"))")
                } else {
                    view.contextView.setTitle("\(from.toFormat("MMM dd, yyyy"))-\(to.toFormat("MMM dd, yyyy"))")
                }
            }
        }
    }
}
