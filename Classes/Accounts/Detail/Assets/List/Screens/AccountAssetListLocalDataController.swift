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
//   AccountAssetListLocalDataController.swift

import Foundation
import MacaroonUtils

final class AccountAssetListLocalDataController:
    AccountAssetListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((AccountAssetListDataControllerEvent) -> Void)?

    private var assets: [AssetInformation] = []

    var addedAssetDetails: [AssetInformation] = []
    var removedAssetDetails: [AssetInformation] = []

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.accountAssetListDataController")

    init(
        _ sharedDataController: SharedDataController
    ) {
        self.sharedDataController = sharedDataController
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension AccountAssetListLocalDataController {
    func load() {
        sharedDataController.add(self)
    }
}

extension AccountAssetListLocalDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didStartRunning:
            break
        case .didFinishRunning:
            break
        case .didUpdateAccountCollection(let accountHandle):
            if accountHandle.isReady {
                deliverContentSnapshot(for: accountHandle)
            }
        case .didUpdateAssetDetailCollection:
            break
        case .didUpdateCurrency:
            break
        default:
            break
        }
    }
}

extension AccountAssetListLocalDataController {
    func deliverContentSnapshot(for accountHandle: AccountHandle) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

//            let portfolioItem: AccountAssetsItem
//            if let totalPortfolioValue = self.calculatePortfolio(for: [account], with: currency) {
//                portfolioItem = .portfolio(PortfolioValueViewModel(.singleAccount(value: .value(totalPortfolioValue)), currency))
//            } else {
//                portfolioItem = .portfolio(PortfolioValueViewModel(.singleAccount(value: .unknown), nil))
//            }
//
//            snapshot.appendSections([.portfolio])
//            snapshot.appendItems(
//                [portfolioItem],
//                toSection: .portfolio
//            )

            var assets: [AssetInformation] = []
            var assetItems: [AccountAssetsItem] = []

            assetItems.append(.search)

            assetItems.append(.asset(AssetPreviewViewModel(AssetPreviewModelAdapter.adapt(accountHandle.value))))

            accountHandle.value.assetInformations.forEach {
                assets.append($0)

                let asset = accountHandle.value.assets!.first(matching: (\.id, $0.id))!
                let assetItem: AccountAssetsItem = .asset(AssetPreviewViewModel(AssetPreviewModelAdapter.adaptAssetSelection(($0, asset))))
                assetItems.append(assetItem)
            }

            self.clearAddedAssetDetailsIfNeeded(for: accountHandle.value)
            self.clearRemovedAssetDetailsIfNeeded(for: accountHandle.value)

            self.addedAssetDetails.forEach {
                let assetItem: AccountAssetsItem = .pendingAsset(PendingAssetPreviewViewModel(AssetPreviewModelAdapter.adaptPendingAsset($0)))
                assetItems.append(assetItem)
            }

            self.removedAssetDetails.forEach {
                let assetItem: AccountAssetsItem = .pendingAsset(PendingAssetPreviewViewModel(AssetPreviewModelAdapter.adaptPendingAsset($0)))
                assetItems.append(assetItem)
            }

            snapshot.appendSections([.assets])
            snapshot.appendItems(
                assetItems,
                toSection: .assets
            )

            return snapshot
        }
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }

            let newSnapshot = snapshot()

            self.lastSnapshot = newSnapshot
            self.publish(.didUpdate(newSnapshot))
        }
    }
}

extension AccountAssetListLocalDataController {
    private func publish(
        _ event: AccountAssetListDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }

    private func clearAddedAssetDetailsIfNeeded(for account: Account) {
        addedAssetDetails = addedAssetDetails.filter { !account.assetInformations.contains($0) }
    }

    private func clearRemovedAssetDetailsIfNeeded(for account: Account) {
        removedAssetDetails = removedAssetDetails.filter { account.assetInformations.contains($0) }
    }
}
