//
//  TransactionHistoryHeaderViewModel.swift

import UIKit

class TransactionHistoryHeaderViewModel {
    private(set) var image: UIImage?
    private(set) var title: String?

    init(filterOption: TransactionFilterViewController.FilterOption) {
        setImage(from: filterOption)
        setTitle(from: filterOption)
    }

    private func setImage(from filterOption: TransactionFilterViewController.FilterOption) {
        switch filterOption {
        case .allTime:
            image = img("icon-transaction-filter")
        case .today:
            image = img("icon-transaction-filter-badge")
        case .yesterday:
            image = img("icon-transaction-filter-badge")
        case .lastWeek:
            image = img("icon-transaction-filter-badge")
        case .lastMonth:
            image = img("icon-transaction-filter-badge")
        case .customRange:
            image = img("icon-transaction-filter-badge")
        }
    }

    private func setTitle(from filterOption: TransactionFilterViewController.FilterOption) {
        switch filterOption {
        case .allTime:
            title = "contacts-transactions-title".localized
        case .today:
            title = "transaction-filter-option-today".localized
        case .yesterday:
            title = "transaction-filter-option-yesterday".localized
        case .lastWeek:
            title = "transaction-filter-option-week".localized
        case .lastMonth:
            title = "transaction-filter-option-month".localized
        case let .customRange(from, to):
            if let from = from,
                let to = to {
                if from.year == to.year {
                    title = "\(from.toFormat("MMM dd"))-\(to.toFormat("MMM dd"))"
                } else {
                    title = "\(from.toFormat("MMM dd, yyyy"))-\(to.toFormat("MMM dd, yyyy"))"
                }
            }
        }
    }
}
