// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASAAccountInboxListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class IncomingASAAccountInboxListDataSource: UICollectionViewDiffableDataSource<IncomingASASection, IncomingASAItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case let .asset(item):
                if item.collectibleAsset != nil {
                    let cell = collectionView.dequeue(
                        CollectibleListItemCell.self,
                        at: indexPath
                    )
                    cell.bindData(item.collectibleViewModel)
                    return cell
                } else {
                    let cell = collectionView.dequeue(
                        IncomingASAAccountInboxListItemCell.self,
                        at: indexPath
                    )
                    cell.bindData(item.viewModel)
                    return cell
                }
            case .assetLoading:
                return collectionView.dequeue(
                    AccountAssetListLoadingCell.self,
                    at: indexPath
                )
            case .empty:
                let cell = collectionView.dequeue(
                    NoContentCell.self,
                    at: indexPath
                )
                cell.bindData(
                    IncomingASAAccountsNoContentViewModel()
                )
                return cell
            }
        }

        [
            IncomingASAAccountInboxHeaderTitleCell.self,
            AccountAssetListLoadingCell.self,
            IncomingASAAccountInboxListItemCell.self,
            CollectibleListItemCell.self,
            NoContentCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
