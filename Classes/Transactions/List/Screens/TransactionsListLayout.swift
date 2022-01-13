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
        guard let dataSource = transactionDataSource?.dataSource else {
            return .zero
        }

        if (draft.type == .algos || draft.type == .asset),
           indexPath.section == 0 {
            return draft.type == .algos ? CGSize(theme.algosInfoSize) : CGSize(theme.assetInfoSize)
        } else if case .title = dataSource.itemIdentifier(for: indexPath) {
            return CGSize(theme.transactionHistoryTitleCellSize)
        } else if case .filter = dataSource.itemIdentifier(for: indexPath) {
            return CGSize(theme.transactionHistoryFilterCellSize)
        } else {
            return CGSize(theme.transactionHistoryCellSize)
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        handlers.willDisplay?(indexPath)
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
