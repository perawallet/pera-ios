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

//
//   AccountAssetListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit
import pera_wallet_core

final class AccountAssetListDataSource: UICollectionViewDiffableDataSource<AccountAssetsSection, AccountAssetsItem> {
    lazy var handlers = Handlers()

    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .accountNotBackedUpWarning(let item):
                let cell = collectionView.dequeue(
                    AccountDetailAccountNotBackedUpWarningCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case let .portfolio(item):
                let cell = collectionView.dequeue(
                    AccountPortfolioCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case let .watchPortfolio(item):
                let cell = collectionView.dequeue(
                    WatchAccountPortfolioCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case .charts(let item):
                let cell = collectionView.dequeue(
                    AccountChartsCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case .assetManagement(let item):
                let cell = collectionView.dequeue(
                    ManagementItemWithSecondaryActionCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item
                )
                return cell
            case .watchAccountAssetManagement(let item):
                let cell = collectionView.dequeue(
                    ManagementItemCell.self,
                    at: indexPath
                )
                cell.bindData(
                    item
                )
                return cell
            case .search:
                return collectionView.dequeue(
                    SearchBarItemCell.self,
                    at: indexPath
                )
            case .assetLoading:
                return collectionView.dequeue(
                    AccountAssetListLoadingCell.self,
                    at: indexPath
                )
            case let .asset(item):
                let cell = collectionView.dequeue(
                    AssetListItemCell.self,
                    at: indexPath
                )
                cell.bindData(item.viewModel)
                return cell
            case let .pendingAsset(item):
                let cell = collectionView.dequeue(
                    PendingAssetListItemCell.self,
                    at: indexPath
                )
                cell.bindData(item.viewModel)
                return cell
            case let .collectibleAsset(item):
                let cell = collectionView.dequeue(
                    CollectibleListItemCell.self,
                    at: indexPath
                )
                cell.bindData(item.viewModel)
                return cell
            case let .pendingCollectibleAsset(item):
                let cell = collectionView.dequeue(
                    PendingCollectibleAssetListItemCell.self,
                    at: indexPath
                )
                cell.bindData(item.viewModel)
                return cell
            case .quickActions:
                let cell = collectionView.dequeue(
                    AccountQuickActionsCell.self,
                    at: indexPath
                )
                return cell
            case .watchAccountQuickActions:
                let cell = collectionView.dequeue(
                    WatchAccountQuickActionsCell.self,
                    at: indexPath
                )
                return cell
            case .empty(let item):
                let cell = collectionView.dequeue(
                    NoContentCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            }
        }

        [
            AccountDetailAccountNotBackedUpWarningCell.self,
            AccountPortfolioCell.self,
            WatchAccountPortfolioCell.self,
            ManagementItemWithSecondaryActionCell.self,
            ManagementItemCell.self,
            SearchBarItemCell.self,
            AccountAssetListLoadingCell.self,
            AssetListItemCell.self,
            PendingAssetListItemCell.self,
            CollectibleListItemCell.self,
            PendingCollectibleAssetListItemCell.self,
            AccountQuickActionsCell.self,
            WatchAccountQuickActionsCell.self,
            NoContentCell.self,
            AccountChartsCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
    
    func reloadPortfolio(with viewModel: PortfolioViewModel) {
        var snapshot = snapshot()
        
        if let accountViewModel = viewModel as? AccountPortfolioViewModel {
            let newItem = AccountAssetsItem.portfolio(accountViewModel)
            snapshot.replaceItem(matching: {
                if case .portfolio = $0 { return true } else { return false }
            }, with: newItem)
        } else if let watchViewModel = viewModel as? WatchAccountPortfolioViewModel {
            let newItem = AccountAssetsItem.watchPortfolio(watchViewModel)
            snapshot.replaceItem(matching: {
                if case .watchPortfolio = $0 { return true } else { return false }
            }, with: newItem)
        }
        apply(snapshot, animatingDifferences: false)
    }
}

extension AccountAssetListDataSource: AddAssetItemViewDelegate {
    func addAssetItemViewDidTapAddAsset(_ addAssetItemView: AddAssetItemView) {
        handlers.didAddAsset?()
    }
}

extension AccountAssetListDataSource {
    struct Handlers {
        var didAddAsset: EmptyHandler?
    }
}
