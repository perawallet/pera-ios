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
//   AccountAssetListAPIDataController.swift

import Foundation
import MacaroonUtils

final class AccountAssetListAPIDataController:
    AccountAssetListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((AccountAssetListDataControllerEvent) -> Void)?

    private var accountHandle: AccountHandle
    private var assets: [StandardAsset] = []

    private var searchKeyword: String? = nil
    private var searchResults: [StandardAsset] = []

    var addedAssetDetails: [StandardAsset] = []
    var removedAssetDetails: [StandardAsset] = []

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.accountAssetListDataController")

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)

    init(
        _ accountHandle: AccountHandle,
        _ sharedDataController: SharedDataController
    ) {
        self.accountHandle = accountHandle
        self.sharedDataController = sharedDataController
    }

    deinit {
        sharedDataController.remove(self)
    }

    subscript(index: Int) -> StandardAsset? {
        var searchResultIndex = index - 2

        if isKeywordContainsAlgo() {
            searchResultIndex = searchResultIndex.advanced(by: -1)
        }

        return searchResults[safe: searchResultIndex]
    }
}

extension AccountAssetListAPIDataController {
    func load() {
        sharedDataController.add(self)
    }
}

extension AccountAssetListAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case let .didStartRunning(first):
            if first ||
               lastSnapshot == nil {
                deliverContentSnapshot()
            }
        case .didFinishRunning:
            if let updatedAccountHandle = sharedDataController.accountCollection[accountHandle.value.address] {
                accountHandle = updatedAccountHandle
            }
            deliverContentSnapshot()
        default:
            break
        }
    }
}

extension AccountAssetListAPIDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            let portfolio = AccountPortfolio(account: self.accountHandle)
            let portfolioItem = AccountPortfolioViewModel(portfolio)

            snapshot.appendSections([.portfolio])
            snapshot.appendItems(
                [.portfolio(portfolioItem)],
                toSection: .portfolio
            )

            snapshot.appendSections([.quickActions])
            snapshot.appendItems(
                [.quickActions],
                toSection: .quickActions
            )

            var assets: [StandardAsset] = []
            var assetItems: [AccountAssetsItem] = []
            
            if !self.accountHandle.value.isWatchAccount() {
                let titleItem: AccountAssetsItem = .assetManagement(
                    ManagementItemViewModel(.asset)
                )
                assetItems.append(titleItem)
            } else {
                let titleItem: AccountAssetsItem = .assetTitle(
                    AssetSearchListHeaderViewModel("accounts-title-assets".localized)
                )
                assetItems.append(titleItem)
            }

            assetItems.append(.search)

            let currency = self.sharedDataController.currency.value

            self.clearAddedAssetDetailsIfNeeded(for: self.accountHandle.value)
            self.clearRemovedAssetDetailsIfNeeded(for: self.accountHandle.value)

            self.load(with: self.searchKeyword)

            if self.isKeywordContainsAlgo() {
                assetItems.append(.algo(AssetPreviewViewModel(AssetPreviewModelAdapter.adapt((self.accountHandle.value, currency)))))
            }

            self.searchResults.forEach { asset in
                if self.removedAssetDetails.contains(asset) {
                    return
                }

                assets.append(asset)
                
                let assetPreview = AssetPreviewModelAdapter.adaptAssetSelection((asset, currency))
                let assetItem: AccountAssetsItem = .asset(AssetPreviewViewModel(assetPreview))
                assetItems.append(assetItem)
            }

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

            if self.searchResults.isEmpty && !self.isKeywordContainsAlgo() {
                snapshot.appendSections([.empty])

                snapshot.appendItems(
                    [ .empty(AssetListSearchNoContentViewModel(hasBody: true)) ],
                    toSection: .empty
                )
            }

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

extension AccountAssetListAPIDataController {
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
        addedAssetDetails = addedAssetDetails.filter { !account.containsAsset($0.id) }.uniqueElements()
    }

    private func clearRemovedAssetDetailsIfNeeded(for account: Account) {
        removedAssetDetails = removedAssetDetails.filter { account.containsAsset($0.id) }.uniqueElements()
    }
}

/// <mark>: Search
extension AccountAssetListAPIDataController {
    func search(for query: String?) {
        searchThrottler.performNext {
            [weak self] in

            guard let self = self else {
                return
            }

            self.resetSearch()

            self.load(with: query)
            self.deliverContentSnapshot()
        }
    }

    private func load(with query: String?) {
        if query.isNilOrEmpty {
            searchKeyword = nil
        } else {
            searchKeyword = query
        }

        guard let searchKeyword = searchKeyword else {
            searchResults = accountHandle.value.standardAssets
            return
        }

        searchResults = accountHandle.value.standardAssets.filter { asset in
            isAssetContainsID(asset, query: searchKeyword) ||
            isAssetContainsName(asset, query: searchKeyword) ||
            isAssetContainsUnitName(asset, query: searchKeyword)
        }
    }

    private func resetSearch() {
        searchResults = accountHandle.value.standardAssets
        deliverContentSnapshot()
    }

    private func isAssetContainsID(_ asset: StandardAsset, query: String) -> Bool {
        return String(asset.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(_ asset: StandardAsset, query: String) -> Bool {
        return asset.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(_ asset: StandardAsset, query: String) -> Bool {
        return asset.unitName.someString.localizedCaseInsensitiveContains(query)
    }

    private func isKeywordContainsAlgo() -> Bool {
        guard let keyword = searchKeyword, !keyword.isEmptyOrBlank else {
            /// <note>: If keyword doesn't contain any word or it's empty, it should return true for adding algo to asset list
            return true
        }

        return "algo".containsCaseInsensitive(keyword)
    }
}
