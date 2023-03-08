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

//   ManageAssetsListDataController.swift

import Foundation
import UIKit

protocol ManageAssetsListDataController: AnyObject {
    var eventHandler: ((ManageAssetsListDataControllerEvent) -> Void)? { get set }

    var account: Account { get }

    func load(query: ManageAssetsListQuery?)
    func hasOptedOut(_ asset: Asset) -> OptOutStatus
}

enum ManageAssetsListSection:
    Int,
    Hashable {
    case assets
    case empty
}

enum ManageAssetsListItem: Hashable {
    case asset(OptOutAssetListItem)
    case collectibleAsset(OptOutCollectibleAssetListItem)
    case empty(ManageAssetsListEmptyItem)
    case loading(String)
}

enum ManageAssetsListEmptyItem: Hashable {
    case noContent
    case noContentSearch
}

extension ManageAssetsListItem {
    var asset: Asset? {
        switch self {
        case .asset(let item): return item.model
        case .collectibleAsset(let item): return item.model
        case .empty: return nil
        case .loading: return nil
        }
    }
}

enum ManageAssetsListDataControllerEvent {
    case didUpdate(ManageAssetsListUpdates)
}

struct ManageAssetsListUpdates {
    let snapshot: Snapshot
}

extension ManageAssetsListUpdates {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ManageAssetsListSection, ManageAssetsListItem>
}
