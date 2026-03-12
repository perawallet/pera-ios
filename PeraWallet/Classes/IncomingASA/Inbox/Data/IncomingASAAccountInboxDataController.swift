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

//   IncomingASAAccountInboxDataController.swift

import Foundation
import UIKit
import pera_wallet_core

protocol IncomingASAAccountInboxDataController: AnyObject {
    var eventHandler: ((IncomingASAListDataControllerEvent) -> Void)? { get set }

    var requestsCount: Int { get }
    var address: String { get }
    
    func load()
    func reload()
}

enum IncomingASASection:
    Int,
    Hashable {
    case title
    case assets
    case empty
}

enum IncomingASAItem: Hashable {
    case assetLoading
    case asset(IncomingASAListItem)
    case empty
}

extension IncomingASAItem {
    var asset: Asset? {
        switch self {
        case .asset(let item): return item.asset
        default: return nil
        }
    }
}

struct IncomingASACollectibleAssetListItem: Hashable {
    let asset: CollectibleAsset
    let senders: Senders?
    let viewModel: CollectibleListItemViewModel

    init(item: CollectibleAssetItem, senders: Senders?) {
        self.asset = item.asset
        self.senders = senders
        self.viewModel = CollectibleListItemViewModel(item: item)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
        hasher.combine(asset.amount)
        hasher.combine(viewModel.primaryTitle?.string)
        hasher.combine(viewModel.secondaryTitle?.string)
    }

    static func == (
        lhs: IncomingASACollectibleAssetListItem,
        rhs: IncomingASACollectibleAssetListItem
    ) -> Bool {
        return
            lhs.asset.id == rhs.asset.id &&
            lhs.asset.amount == rhs.asset.amount &&
            lhs.viewModel.primaryTitle?.string == rhs.viewModel.primaryTitle?.string &&
            lhs.viewModel.secondaryTitle?.string == rhs.viewModel.secondaryTitle?.string
    }
}

enum IncomingASAListDataControllerEvent {
    case didUpdate(IncomingASAListUpdates)
    case didReceiveError(String)
}

struct IncomingASAListUpdates {
    let snapshot: Snapshot
    let operation: Operation
}

extension IncomingASAListUpdates {
    enum Operation {
        /// Reload by the last query
        case refresh
    }
}

extension IncomingASAListUpdates {
    typealias Snapshot = NSDiffableDataSourceSnapshot<IncomingASASection, IncomingASAItem>
    typealias Completion = () -> Void
}
