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

//   ManageAssetsListLocalDataController.swift

import Foundation
import MacaroonUtils

final class ManageAssetsListLocalDataController:
    ManageAssetsListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((ManageAssetsListDataControllerEvent) -> Void)?

    private lazy var asyncLoadingQueue = createAsyncLoadingQueue()
    private lazy var collectibleAmountFormatter = createCollectibleAmountFormatter()
    private lazy var currencyFormatter = createCurrencyFormatter()
    private lazy var searchThrottler = createSearchThrottler()
    
    private(set) var account: Account
    private var allAssets: [Asset] = []
    private var displayedAssets: [Asset] = []
    
    private var lastSnapshot: Snapshot?
    private var lastQuery: String?
    
    private let sharedDataController: SharedDataController

    init(
        account: Account,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.sharedDataController = sharedDataController
    }
    
    deinit {
        cancelOngoingSearching()
        sharedDataController.remove(self)
    }
    
    func load() {
        sharedDataController.add(self)
    }
    
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            guard let upToDateAccount = sharedDataController.accountCollection[account.address] else {
                return
            }
            
            if case .failed = upToDateAccount.status {
                return
            }
            
            self.account = upToDateAccount.value
            
            reload()
        }
    }
}

extension ManageAssetsListLocalDataController {
    func search(for query: String) {
        lastQuery = query
        cancelOngoingLoading()
        deliverLoadingSnapshot()
        
        searchThrottler.performNext {
            [weak self] in
            guard let self else { return }
            
            let task = AsyncTask {
                [weak self] completionBlock in
                guard let self else { return }
                
                defer {
                    completionBlock()
                }
                
                self.configureDisplayedAssets()
                self.deliverContentSnapshot()
            }
            self.asyncLoadingQueue.add(task)
            self.asyncLoadingQueue.resume()
        }
    }
    
    func resetSearch() {
        lastQuery = nil
        cancelOngoingSearching()
        
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }
            
            defer {
                completionBlock()
            }
            self.configureDisplayedAssets()
            self.deliverContentSnapshot()
        }
        
        asyncLoadingQueue.add(task)
        asyncLoadingQueue.resume()
        
    }
    
    private func reload() {
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }
            
            defer {
                completionBlock()
            }
            
            self.configureAccountAssets()
            self.configureDisplayedAssets()
            self.deliverContentSnapshot()
        }
        
        asyncLoadingQueue.add(task)
    }
    
    private func configureAccountAssets() {
        guard let accountAssets = account.allAssets else {
            allAssets.removeAll()
            return
        }
        
        allAssets = accountAssets.filter {
            $0.creator?.address != account.address
        }
    }

    private func configureDisplayedAssets() {
        guard let searchQuery = lastQuery,
              !searchQuery.isEmpty else {
            displayedAssets = allAssets
            return
        }
        
        displayedAssets = allAssets.filter { asset in
            isAssetContainsID(asset, query: searchQuery) ||
            isAssetContainsName(asset, query: searchQuery) ||
            isAssetContainsUnitName(asset, query: searchQuery)
        }
    }
    
    private func isAssetContainsID(_ asset: Asset, query: String) -> Bool {
        return String(asset.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(_ asset: Asset, query: String) -> Bool {
        return asset.naming.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(_ asset: Asset, query: String) -> Bool {
        return asset.naming.unitName.someString.localizedCaseInsensitiveContains(query)
    }
    
    private func cancelOngoingSearching() {
        searchThrottler.cancelAll()
        cancelOngoingLoading()
    }

    private func cancelOngoingLoading() {
        asyncLoadingQueue.cancel()
    }
}

extension ManageAssetsListLocalDataController {
    private func deliverLoadingSnapshot() {
        let loadingSnapshot = makeSnapshotForLoading()
        lastSnapshot = loadingSnapshot
        
        publish(event: .didUpdate(loadingSnapshot))
    }
    
    private func makeSnapshotForLoading() -> Snapshot {
        var snapshot = Snapshot()
        let items: [ManageAssetsListItem] = [.loading]
        snapshot.appendSections([.assets])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
        
        return snapshot
    }
    
    private func deliverContentSnapshot() {
        guard !allAssets.isEmpty else {
            deliverNoContentSnapshot()
            return
        }
        
        guard !displayedAssets.isEmpty else {
            deliverEmptyContentSnapshot()
            return
        }
        
        let contentSnapshot = makeSnapshotForContent()
        lastSnapshot = contentSnapshot
        self.publish(event: .didUpdate(contentSnapshot))
    }
    
    private func deliverNoContentSnapshot() {
        let noContentSnapshot = makeNoContentSnapshot()
        lastSnapshot = noContentSnapshot
        
        publish(event: .didUpdate(noContentSnapshot))
    }
    
    private func makeNoContentSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.empty(AssetListSearchNoContentViewModel(hasBody: false))],
            toSection: .empty
        )
        
        return snapshot
    }
    
    private func deliverEmptyContentSnapshot() {
        let emptyContentSnapshot = makeSnapshotForEmptyContent()
        lastSnapshot = emptyContentSnapshot
        
        publish(event: .didUpdate(emptyContentSnapshot))
    }
    
    private func makeSnapshotForEmptyContent() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.empty(AssetListSearchNoContentViewModel(hasBody: true))],
            toSection: .empty
        )
        
        return snapshot
    }
    
    private func makeSnapshotForContent() -> Snapshot {
        let listItems = configureListItems()
        
        var snapshot = Snapshot()
        snapshot.appendSections([.assets])
        snapshot.appendItems(
            listItems,
            toSection: .assets
        )

        return snapshot
    }
    
    private func configureListItems() -> [ManageAssetsListItem] {
        var items: [ManageAssetsListItem] = []
        
        self.displayedAssets.forEach { asset in
            if let collectibleAsset = asset as? CollectibleAsset {
                let collectibleAssetItem = self.makeCollectibleAssetItem(collectibleAsset)
                items.append(collectibleAssetItem)
                return
            }

            if let standardAsset = asset as? StandardAsset {
                let assetItem = self.makeStandardAssetItem(standardAsset)
                items.append(assetItem)
                return
            }
        }
        
        if let selectedAccountAssetSortingAlgorithm = self.sharedDataController.selectedAccountAssetSortingAlgorithm {
            items.sort {
                guard let firstItem = $0.asset,
                      let secondItem = $1.asset else {
                    return false
                }
                
                return selectedAccountAssetSortingAlgorithm.getFormula(
                    asset: firstItem,
                    otherAsset: secondItem
                )
            }
        }
        
        return items
    }
    
    private func makeStandardAssetItem(_ asset: StandardAsset) -> ManageAssetsListItem {
        let currency = sharedDataController.currency
        let currencyFormatter = currencyFormatter
        let item = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let listItem = OptOutAssetListItem(item: item)
        return .asset(listItem)
    }

    private func makeCollectibleAssetItem(_ asset: CollectibleAsset) -> ManageAssetsListItem {
        let item = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let listItem = OptOutCollectibleAssetListItem(item: item)
        return .collectibleAsset(listItem)
    }
}

extension ManageAssetsListLocalDataController {
    private func publish(event: ManageAssetsListDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self else { return }

            self.eventHandler?(event)
        }
    }
}

extension ManageAssetsListLocalDataController {
    func hasOptedOut(_ asset: Asset) -> OptOutStatus {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptedOut = monitor.hasPendingOptOutRequest(
            assetID: asset.id,
            for: account
        )
        let hasAlreadyOptedOut = account[asset.id] == nil

        switch (hasPendingOptedOut, hasAlreadyOptedOut) {
        case (true, false): return .pending
        case (true, true): return .optedOut
        case (false, true): return .optedOut
        case (false, false): return .rejected
        }
    }
}

extension ManageAssetsListLocalDataController {
    private func createAsyncLoadingQueue() -> AsyncSerialQueue {
        let underlyingQueue = DispatchQueue(
            label: "pera.queue.manageAssets.updates",
            qos: .userInitiated
        )
        return .init(
            name: "manageAssetsListDataController.asyncLoadingQueue",
            underlyingQueue: underlyingQueue
        )
    }
    
    private func createCollectibleAmountFormatter() -> CollectibleAmountFormatter {
        return .init()
    }
    
    private func createCurrencyFormatter() -> CurrencyFormatter {
        return .init()
    }
    
    private func createSearchThrottler() -> Throttler {
        return .init(intervalInSeconds: 0.4)
    }
}
