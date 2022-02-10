// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   TransactionsListLayout.swift

import UIKit

final class TransactionsListLayout: NSObject {
    private lazy var theme = Theme()
    lazy var handlers = Handlers()

    private let draft: TransactionListing
    private weak var transactionsDataSource: TransactionsDataSource?

    init(draft: TransactionListing, transactionsDataSource: TransactionsDataSource?) {
        self.draft = draft
        self.transactionsDataSource = transactionsDataSource
        super.init()
    }
}

extension TransactionsListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = transactionsDataSource?.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .algosInfo:
            return CGSize(theme.algosInfoSize)
        case .assetInfo:
            return CGSize(theme.assetInfoSize)
        case .filter:
            return CGSize(theme.transactionHistoryFilterCellSize)
        case .transaction, .pending, .reward:
            return CGSize(theme.transactionHistoryCellSize)
        case .title:
            return CGSize(theme.transactionHistoryTitleCellSize)
        case .empty(let emptyState):
            switch emptyState {
            case .algoTransactionHistoryLoading:
                let cellHeight = AlgoTransactionHistoryLoadingCell.height(
                    for: AlgoTransactionHistoryLoadingViewCommonTheme()
                )
                return CGSize(width: collectionView.bounds.width - 48, height: cellHeight)
            case .transactionHistoryLoading:
                return CGSize(width: collectionView.bounds.width - 48, height: 500)
            default:
                let width = collectionView.bounds.width
                var height = collectionView.bounds.height -
                collectionView.adjustedContentInset.bottom -
                collectionView.contentInset.top -
                theme.transactionHistoryTitleCellSize.h
                if draft.type != .all {
                    height -= draft.type == .algos ? theme.algosInfoSize.h : theme.assetInfoSize.h
                }
                return CGSize((width, height))
            }

        case .nextList:
            return CGSize((collectionView.bounds.width, 100))
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        handlers.willDisplay?(cell, indexPath)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let loadingCell = cell as? LoadingCell {
            loadingCell.stopAnimating()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        handlers.didSelect?(indexPath)
    }
}

extension TransactionsListLayout {
    struct Handlers {
        var willDisplay: ((UICollectionViewCell, IndexPath) -> Void)?
        var didSelect: ((IndexPath) -> Void)?
    }
}
