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
    
    private var nextQuery: ManageAssetsListQuery?
    private var lastQuery: ManageAssetsListQuery?
    private var lastSnapshot: Snapshot?
    
    private var canDeliverUpdatesForAssets = false
    
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
}

extension ManageAssetsListLocalDataController {
    func load(query: ManageAssetsListQuery?) {
        nextQuery = query
        
        if canDeliverUpdatesForAssets {
            loadNext(query: query)
        } else {
            loadFirst(query: query)
        }
    }
    
    func loadNext(query: ManageAssetsListQuery?) {
        if query == lastQuery {
            nextQuery = nil
            return
        }
        
        if query?.keyword == lastQuery?.keyword {
            customize(query: query)
        } else {
            search(query: query)
        }
    }
    
    func customize(query: ManageAssetsListQuery?) {
        cancelOngoingSearching()
        deliverUpdatesForLoading()
        
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }
            
            defer {
                completionBlock()
            }
            
            self.deliverUpdatesForContent(
                when: { query == self.nextQuery },
                query: query
            )
        }
        asyncLoadingQueue.add(task)
        asyncLoadingQueue.resume()
    }
    
    func search(query: ManageAssetsListQuery?) {
        cancelOngoingLoading()
        deliverUpdatesForLoading()
        
        searchThrottler.performNext {
            [weak self] in
            guard let self else { return }
            
            let task = AsyncTask {
                [weak self] completionBlock in
                guard let self else { return }
                
                defer {
                    completionBlock()
                }
                
                self.deliverUpdatesForContent(
                    when: { query == self.nextQuery },
                    query: query
                )
            }
            self.asyncLoadingQueue.add(task)
            self.asyncLoadingQueue.resume()
        }
    }
    
    private func loadFirst(query: ManageAssetsListQuery?) {
        deliverUpdatesForLoading()

        lastQuery = query
        nextQuery = nil
        sharedDataController.add(self)
    }
}

extension ManageAssetsListLocalDataController {
    private func reload() {
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }
            
            defer {
                completionBlock()
            }
            
            self.deliverUpdatesForContent(
                when: { self.nextQuery == nil },
                query: self.lastQuery
            )
        }
        asyncLoadingQueue.add(task)
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
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            canDeliverUpdatesForAssets = true
            
            if let upToDateAccount = sharedDataController.accountCollection[account.address]?.value {
                account = upToDateAccount
                reload()
            }
        }
    }
}

extension ManageAssetsListLocalDataController {
    private func deliverUpdatesForLoading() {
        let updates = makeUpdatesForLoading()
        publish(updates: updates)
    }
    
    private func makeUpdatesForLoading() -> Updates {
        var snapshot = Snapshot()
        appendSectionForAssetsLoading(into: &snapshot)
        return Updates(snapshot: snapshot)
    }
    
    private func appendSectionForAssetsLoading(into snapshot: inout Snapshot) {
        let items: [ManageAssetsListItem] = [.loading("1"), .loading("2")]
        snapshot.appendSections([.assets])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
    }
}

extension ManageAssetsListLocalDataController {
    private func makeUpdatesForNoContent() -> Updates {
        var snapshot = Snapshot()
        appendSectionForNoContent(into: &snapshot)
        return Updates(snapshot: snapshot)
    }
    
    private func appendSectionForNoContent(into snapshot: inout Snapshot) {
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.empty(.noContent)],
            toSection: .empty
        )
    }
    
    private func makeUpdatesForSearchNoContent() -> Updates {
        var snapshot = Snapshot()
        appendSectionForSearchNoContent(into: &snapshot)
        return Updates(snapshot: snapshot)
    }
    
    private func appendSectionForSearchNoContent(into snapshot: inout Snapshot) {
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.empty(.noContentSearch)],
            toSection: .empty
        )
    }
}

extension ManageAssetsListLocalDataController {
    private func deliverUpdatesForContent(
        when condition: () -> Bool,
        query: ManageAssetsListQuery?
    ) {
        let updates = makeUpdatesForContent(query: query)
        
        if !condition() { return }
        
        self.lastQuery = query
        self.nextQuery = nil
        
        self.publish(updates: updates)
    }
    
    private func makeUpdatesForContent(
        query: ManageAssetsListQuery?
    ) -> Updates {
        let listItems = makeOptOutListItems(query)
        
        let shouldShowEmptyContent = listItems.isEmpty
        
        if shouldShowEmptyContent {
            let isSearching = !(query?.keyword.isNilOrEmpty ?? true)
            return isSearching ? makeUpdatesForSearchNoContent() : makeUpdatesForNoContent()
        }
        
        var snapshot = Snapshot()
        
        appendSectionContent(
            query: query,
            items: listItems,
            into: &snapshot
        )
        
        return Updates(snapshot: snapshot)
    }
    
    private func appendSectionContent(
        query: ManageAssetsListQuery?,
        items: [ManageAssetsListItem],
        into snapshot: inout Snapshot
    ) {
        snapshot.appendSections([.assets])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
    }
    
    private func makeOptOutListItems(
        _ query: ManageAssetsListQuery?
    ) -> [ManageAssetsListItem] {
        let assets = account.allAssets
        
        let assetItems: [ManageAssetsListItem] = assets.someArray.compactMap {
            asset in
            
            if let query,
               !query.matches(
                asset: asset,
                account: account
               ) {
                return nil
            }
            
            if let collectibleAsset = asset as? CollectibleAsset {
                return makeCollectibleAssetItem(collectibleAsset)
            }
            
            if let standardAsset = asset as? StandardAsset {
                return makeStandardAssetItem(standardAsset)
            }
            
            return nil
        }
        
        guard let sortingAlgorithm = query?.sortingAlgorithm else {
            return assetItems
        }
        
        return assetItems.sorted {
            guard let firstItem = $0.asset,
                  let secondItem = $1.asset else {
                return false
            }
            
            return sortingAlgorithm.getFormula(
                asset: firstItem,
                otherAsset: secondItem
            )
        }
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
}

extension ManageAssetsListLocalDataController {
    private func publish(updates: Updates) {
        lastSnapshot = updates.snapshot
        publish(event: .didUpdate(updates))
    }
    
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

extension ManageAssetsListLocalDataController {
    typealias Updates = ManageAssetsListUpdates
    typealias Snapshot = ManageAssetsListUpdates.Snapshot
}
