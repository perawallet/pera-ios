// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MoonPayAccountSelectionListDataSource.swift

import Foundation
import UIKit

final class MoonPayAccountSelectionListDataSource: AccountSelectionListDataSource {
    typealias SectionIdentifierType = MoonPayAccountSelectionListSectionIdentifier
    typealias ItemIdentifierType = MoonPayAccountSelectionListItemIdentifier

    private unowned let itemDataSource: MoonPayAccountSelectionListItemDataSource

    init(_ itemDataSource: MoonPayAccountSelectionListItemDataSource) {
        self.itemDataSource = itemDataSource
    }

    var supportedCells: [UICollectionViewCell.Type] = [
        AccountSelectionListLoadingAccountItemCell.self,
        AccountSelectionListNoContentCell.self,
        MoonPayAccountSelectionListAccountListItemCell.self
    ]

    func getCellProvider() -> CellProvider {
        return { collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .loading(let item):
                switch item {
                case .account:
                    return collectionView.dequeue(
                        AccountSelectionListLoadingAccountItemCell.self,
                        at: indexPath
                    )
                }
            case .empty(let item):
                switch item {
                case .noContent:
                    let cell = collectionView.dequeue(
                        AccountSelectionListNoContentCell.self,
                        at: indexPath
                    )
                    let viewModel = self.itemDataSource.noContentItem
                    cell.bindData(viewModel)
                    return cell
                }
            case .account(let item):
                let cell = collectionView.dequeue(
                    MoonPayAccountSelectionListAccountListItemCell.self,
                    at: indexPath
                )
                let viewModel = self.itemDataSource.accountItems[item.accountAddress]
                cell.bindData(viewModel)
                return cell
            }
        }
    }

    var supportedSupplementaryViews: [UICollectionReusableView.Type] = [
        MoonPayAccountSelectionListHeader.self
    ]

    func getSupplementaryViewProvider(_ dataSource: DataSource) -> SupplementaryViewProvider? {
        return { collectionView, elementKind, indexPath in

            let header = collectionView.dequeueHeader(
                MoonPayAccountSelectionListHeader.self,
                at: indexPath
            )
            let viewModel = self.itemDataSource.headerItem
            header.bindData(viewModel)

            return header
        }
    }
}
