// Copyright 2019 Algorand, Inc.

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
    private weak var transactionDataSource: TransactionListDataSource?

    init(draft: TransactionListing, transactionDataSource: TransactionListDataSource?) {
        self.draft = draft
        self.transactionDataSource = transactionDataSource
        super.init()
    }
}

extension TransactionsListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let itemIdentifier = transactionDataSource?.dataSource.itemIdentifier(for: indexPath) else {
            return CGSize((collectionView.bounds.width, 0))
        }

        switch itemIdentifier {
        case .info:
            return draft.type == .algos ? CGSize(theme.algosInfoSize) : CGSize(theme.assetInfoSize)
        case .filter:
            return CGSize(theme.transactionHistoryFilterCellSize)
        case .transaction, .pending, .reward:
            return CGSize(theme.transactionHistoryCellSize)
        case .title:
            return CGSize(theme.transactionHistoryTitleCellSize)
        case .empty:
            let width = collectionView.bounds.width
            let height =
            collectionView.bounds.height -
            collectionView.adjustedContentInset.bottom
            return CGSize((width, height))
        case .nextList:
            return CGSize((collectionView.bounds.width, 100))
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let loadingCell = cell as? LoadingCell {
            loadingCell.startAnimating()
            return
        }

        handlers.willDisplay?(indexPath)
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transactionDataSource = transactionDataSource,
              case .transaction(let transaction) = transactionDataSource.dataSource.itemIdentifier(for: indexPath) else {
                  return
              }

        handlers.didSelectTransaction?(transaction)
    }
}

extension TransactionsListLayout {
    struct Handlers {
        var didSelectTransaction: ((Transaction) -> Void)?
        var willDisplay: ((IndexPath) -> Void)?
    }
}
