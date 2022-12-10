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
//   AccountAssetListDataController.swift

import Foundation
import UIKit

protocol AccountAssetListDataController: AnyObject {
    var eventHandler: ((AccountAssetListDataControllerEvent) -> Void)? { get set }

    func load()
    func reload()
    func reloadIfThereIsPendingUpdates()
}

enum AccountAssetsSection:
    Int,
    Hashable {
    case portfolio
    case quickActions
    case assets
    case empty
}

enum AccountAssetsItem: Hashable {
    case portfolio(AccountPortfolioViewModel)
    case watchPortfolio(WatchAccountPortfolioViewModel)
    case search
    case asset(AccountAssetsAssetListItem)
    case pendingAsset(AccountAssetsPendingAssetListItem)
    case collectibleAsset(AccountAssetsCollectibleAssetListItem)
    case pendingCollectibleAsset(AccountAssetsPendingCollectibleAssetListItem)
    case assetManagement(ManagementItemViewModel)
    case watchAccountAssetManagement(ManagementItemViewModel)
    case quickActions
    case empty(AssetListSearchNoContentViewModel)
}

extension AccountAssetsItem {
    var asset: Asset? {
        switch self {
        case .asset(let item): return item.asset
        case .collectibleAsset(let item): return item.asset
        default: return nil
        }
    }
}

struct AccountAssetsAssetListItem: Hashable {
    let asset: Asset
    let viewModel: AssetListItemViewModel

    init(item: AssetItem) {
        self.asset = item.asset
        self.viewModel = AssetListItemViewModel(item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
    }

    static func == (
        lhs: AccountAssetsAssetListItem,
        rhs: AccountAssetsAssetListItem
    ) -> Bool {
        return lhs.asset.id == rhs.asset.id
    }
}

struct AccountAssetsCollectibleAssetListItem: Hashable {
    let asset: CollectibleAsset
    let viewModel: NFTListItemViewModel

    init(item: CollectibleAssetItem) {
        self.asset = item.asset
        self.viewModel = NFTListItemViewModel(item: item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
    }

    static func == (
        lhs: AccountAssetsCollectibleAssetListItem,
        rhs: AccountAssetsCollectibleAssetListItem
    ) -> Bool {
        return lhs.asset.id == rhs.asset.id
    }
}

struct AccountAssetsPendingCollectibleAssetListItem: Hashable {
    private let assetID: AssetID
    let viewModel: NFTListItemViewModel

    init(update: OptInBlockchainUpdate) {
       self.assetID = update.assetID
       self.viewModel = NFTListItemViewModel(update: update)
   }

    init(update: OptOutBlockchainUpdate) {
       self.assetID = update.assetID
       self.viewModel = NFTListItemViewModel(update: update)
   }

    func hash(into hasher: inout Hasher) {
        hasher.combine(assetID)
    }

    static func == (
        lhs: AccountAssetsPendingCollectibleAssetListItem,
        rhs: AccountAssetsPendingCollectibleAssetListItem
    ) -> Bool {
        return lhs.assetID == rhs.assetID
    }
}

struct AccountAssetsPendingAssetListItem: Hashable {
    let assetID: AssetID
    let viewModel: AssetListItemViewModel

    init(update: OptInBlockchainUpdate) {
       self.assetID = update.assetID
       self.viewModel = AssetListItemViewModel(update: update)
   }

    init(update: OptOutBlockchainUpdate) {
       self.assetID = update.assetID
       self.viewModel = AssetListItemViewModel(update: update)
   }

    func hash(into hasher: inout Hasher) {
        hasher.combine(assetID)
    }

    static func == (
        lhs: AccountAssetsPendingAssetListItem,
        rhs: AccountAssetsPendingAssetListItem
    ) -> Bool {
        return lhs.assetID == rhs.assetID
    }
}

enum AccountAssetListDataControllerEvent {
    case didUpdate(AccountAssetListUpdates)
}

struct AccountAssetListUpdates {
    var isNewSearch = false
    var completion: Completion?

    let snapshot: Snapshot

    init(snapshot: Snapshot) {
        self.snapshot = snapshot
    }
}

extension AccountAssetListUpdates {
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountAssetsSection, AccountAssetsItem>
    typealias Completion = () -> Void
}
