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

//   IncomingASAAccountInboxDataController.swift

import Foundation
import UIKit

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

struct IncomingASAListItem: Hashable {
    let asset: Asset
    let collectibleAsset: CollectibleAsset?
    let senders: Senders?
    let viewModel: IncomingASAAssetListItemViewModel
    let collectibleViewModel: CollectibleListItemViewModel?
    let accountAddress: String?
    let totalAmount: UInt64?
    let algoGainOnClaim: UInt64?
    let algoGainOnReject: UInt64?
    let inboxAddress: String?
    let shouldUseFundsBeforeClaiming: Bool
    let hasInsufficientAlgoForClaiming: Bool
    let shouldUseFundsBeforeRejecting: Bool
    let hasInsufficientAlgoForRejecting: Bool
    
    init(
        item: AssetItem,
        collectibleAssetItem: CollectibleAssetItem?,
        senders: Senders?,
        accountAddress: String?,
        inboxAddress: String?,
        totalAmount: UInt64?,
        algoGainOnClaim: UInt64?,
        algoGainOnReject: UInt64?,
        shouldUseFundsBeforeClaiming: Bool,
        hasInsufficientAlgoForClaiming: Bool,
        shouldUseFundsBeforeRejecting: Bool,
        hasInsufficientAlgoForRejecting: Bool
    ) {
        self.asset = item.asset
        self.collectibleAsset = collectibleAssetItem?.asset
        self.senders = senders
        if let item = collectibleAssetItem {
            self.collectibleViewModel = CollectibleListItemViewModel(item: item)
        } else {
            self.collectibleViewModel = nil
        }
        self.viewModel = IncomingASAAssetListItemViewModel(
            item: item, 
            senders: senders,
            totalAmount: totalAmount,
            isCollectible: self.collectibleViewModel != nil
        )
        self.accountAddress = accountAddress
        self.inboxAddress = inboxAddress
        self.totalAmount = totalAmount
        self.algoGainOnClaim = algoGainOnClaim
        self.algoGainOnReject = algoGainOnReject
        self.shouldUseFundsBeforeClaiming = shouldUseFundsBeforeClaiming
        self.hasInsufficientAlgoForClaiming = hasInsufficientAlgoForClaiming
        self.shouldUseFundsBeforeRejecting = shouldUseFundsBeforeRejecting
        self.hasInsufficientAlgoForRejecting = hasInsufficientAlgoForRejecting
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset.id)
        hasher.combine(viewModel.title?.primaryTitle?.string)
        hasher.combine(viewModel.title?.secondaryTitle?.string)
        hasher.combine(viewModel.primaryValue?.string)
        hasher.combine(viewModel.secondaryValue?.string)
        hasher.combine(collectibleAsset?.id)
        hasher.combine(collectibleAsset?.amount)
        hasher.combine(collectibleViewModel?.primaryTitle?.string)
        hasher.combine(collectibleViewModel?.secondaryTitle?.string)
    }

    static func == (
        lhs: IncomingASAListItem,
        rhs: IncomingASAListItem
    ) -> Bool {
        return
            lhs.asset.id == rhs.asset.id &&
            lhs.viewModel.title?.primaryTitle?.string == rhs.viewModel.title?.primaryTitle?.string &&
            lhs.viewModel.title?.secondaryTitle?.string == rhs.viewModel.title?.secondaryTitle?.string &&
            lhs.viewModel.primaryValue?.string == rhs.viewModel.primaryValue?.string &&
            lhs.viewModel.secondaryValue?.string == rhs.viewModel.secondaryValue?.string &&
            lhs.collectibleAsset?.id == rhs.collectibleAsset?.id &&
            lhs.collectibleAsset?.amount == rhs.collectibleAsset?.amount &&
            lhs.collectibleViewModel?.primaryTitle?.string == rhs.collectibleViewModel?.primaryTitle?.string &&
            lhs.collectibleViewModel?.secondaryTitle?.string == rhs.collectibleViewModel?.secondaryTitle?.string
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
