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

//   IncomingASAAccountInboxAPIDataController.swift

import Foundation
import MacaroonUtils

final class IncomingASAAccountInboxAPIDataController:
    IncomingASAAccountInboxDataController,
    SharedDataControllerObserver {
    var eventHandler: ((IncomingAsaListDataControllerEvent) -> Void)?
    
    private(set) var account: AccountHandle

    private lazy var asyncLoadingQueue = createAsyncLoadingQueue()

    private lazy var currencyFormatter = createCurrencyFormatter()
    private lazy var assetAmountFormatter = createAssetAmountFormatter()
    private lazy var minBalanceCalculator = createMinBalanceCalculator()

    private var accountNotBackedUpWarningViewModel: AccountDetailAccountNotBackedUpWarningModel?

    private var nextQuery: AccountAssetListQuery?
    private var lastQuery: AccountAssetListQuery?
    private var lastSnapshot: Snapshot?

    private var canDeliverUpdatesForAssets = false

    private let sharedDataController: SharedDataController

    init(
        account: AccountHandle,
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

extension IncomingASAAccountInboxAPIDataController {
    func load(query: AccountAssetListQuery?) {
        nextQuery = query

        if canDeliverUpdatesForAssets {
            loadNext(query: query)
        } else {
            loadFirst(query: query)
        }
    }

    private func loadNext(query: AccountAssetListQuery?) {
        if query == lastQuery {
            nextQuery = nil
            return
        }

        if query?.keyword == lastQuery?.keyword {
            customize(query: query)
        }
    }

    private func customize(query: AccountAssetListQuery?) {
        cancelOngoingSearching()
        deliverUpdatesForLoading(for: .customize)

        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            self.deliverUpdatesForContent(
                when: { query == self.nextQuery },
                query: query,
                for: .customize
            )
        }
        asyncLoadingQueue.add(task)
        asyncLoadingQueue.resume()
    }

    private func loadFirst(query: AccountAssetListQuery?) {
        deliverUpdatesForLoading(for: .customize)

        lastQuery = query
        nextQuery = nil
        sharedDataController.add(self)
    }

    func reloadIfNeededForPendingAssetRequests() {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        if monitor.hasAnyPendingOptInRequest(for: account.value) ||
           monitor.hasAnyPendingOptOutRequest(for: account.value) {
            reload()
        }
    }

    func reload() {
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            self.deliverUpdatesForContent(
                when: { self.nextQuery == nil },
                query: self.lastQuery,
                for: .refresh
            )
        }
        asyncLoadingQueue.add(task)
    }

    private func cancelOngoingSearching() {
        cancelOngoingLoading()
    }

    private func cancelOngoingLoading() {
        asyncLoadingQueue.cancel()
    }
}

extension IncomingASAAccountInboxAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            canDeliverUpdatesForAssets = true

            if let upToDateAccount = sharedDataController.accountCollection[account.value.address] {
                account = upToDateAccount
                reload()
            }
        }
    }
}

extension IncomingASAAccountInboxAPIDataController {
    private func deliverUpdatesForLoading(for operation: Updates.Operation) {
//        if lastSnapshot?.itemIdentifiers(inSection: .assets).last == .assetLoading {
//            return
//        }
//
//        let updates = makeUpdatesForLoading(for: operation)
//        publish(updates: updates)
    }

    private func makeUpdatesForLoading(for operation: Updates.Operation) -> Updates {
        var snapshot = Snapshot()
        appendSectionForTitle(into: &snapshot)
        return Updates(snapshot: snapshot, operation: operation)
    }

    private func deliverUpdatesForContent(
        when condition: () -> Bool,
        query: AccountAssetListQuery?,
        for operation: Updates.Operation
    ) {
        let updates = makeUpdatesForContent(
            query: query,
            for: operation
        )

        if !condition() { return }

        self.lastQuery = query
        self.nextQuery = nil
        self.publish(updates: updates)
    }

    private func makeUpdatesForContent(
        query: AccountAssetListQuery?,
        for operation: Updates.Operation
    ) -> Updates {
        var snapshot = Snapshot()
        appendSectionForTitle(into: &snapshot)
        appendSectionsForAssets(
            query: query,
            into: &snapshot
        )
        return Updates(snapshot: snapshot, operation: operation)
    }
}

extension IncomingASAAccountInboxAPIDataController {
    
    private func appendSectionForTitle(into snapshot: inout Snapshot) {
        let items = makeItemForTitle()
        snapshot.appendSections([.title])
        snapshot.appendItems(
            items,
            toSection: .title
        )
    }

    private func appendSectionsForAssets(
        query: AccountAssetListQuery?,
        into snapshot: inout Snapshot
    ) {
        let assetItems = makeItemsForPendingAssetRequests() + makeItemsForAssets(query: query)

        let items = assetItems
        snapshot.appendSections([ .assets ])
        snapshot.appendItems(
            items,
            toSection: .assets
        )

        if assetItems.isEmpty {
            appendSectionsForNotFound(into: &snapshot)
        }
    }

    private func appendSectionsForNotFound(into snapshot: inout Snapshot) {
        let items = makeItemsForNotFound()
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            items,
            toSection: .empty
        )
    }
}

extension IncomingASAAccountInboxAPIDataController {

    
    private func makeItemForTitle() -> [IncomingAsaItem] {
        let viewModel = IncomingASAAccountInboxHeaderTitleCellViewModel()
        return [.title(viewModel)]
    }

    private func makeItemsForPendingAssetRequests() -> [IncomingAsaItem] {
        return
            makeItemsForPendingAssetOptInRequests() +
            makeItemsForPendingAssetOptOutRequests() +
            makeItemsForPendingAssetSendRequests()
    }

    private func makeItemsForPendingAssetOptInRequests() -> [IncomingAsaItem] {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let updates = monitor.filterPendingOptInAssetUpdates(for: account.value)
        return updates.map {
            let update = $0.value
            if update.isCollectibleAsset {
                return makeItemForPendingNFTAssetOptInRequest(update)
            } else {
                return makeItemForPendingNonNFTAssetOptInRequest(update)
            }
        }
    }

    private func makeItemForPendingNFTAssetOptInRequest(
        _ update: OptInBlockchainUpdate
    ) -> IncomingAsaItem {
//        let item = AccountAssetsPendingCollectibleAssetListItem(update: update)
//        return .pendingCollectibleAsset(item)
        .empty(.init(hasBody: false))
    }

    private func makeItemForPendingNonNFTAssetOptInRequest(
        _ update: OptInBlockchainUpdate
    ) -> IncomingAsaItem {
//        let item = AccountAssetsPendingAssetListItem(update: update)
//        return .pendingAsset(item)
        .empty(.init(hasBody: false))
    }

    private func makeItemsForPendingAssetOptOutRequests() -> [IncomingAsaItem] {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let updates = monitor.filterPendingOptOutAssetUpdates(for: account.value)
        return updates.map {
            let update = $0.value
            if update.isCollectibleAsset {
                return makeItemForPendingNFTAssetOptOutRequest(update)
            } else {
                return makeItemForPendingNonNFTAssetOptOutRequest(update)
            }
        }
    }

    private func makeItemForPendingNFTAssetOptOutRequest(
        _ update: OptOutBlockchainUpdate
    ) -> IncomingAsaItem {
//        let item = AccountAssetsPendingCollectibleAssetListItem(update: update)
//        return .pendingCollectibleAsset(item)
        .empty(.init(hasBody: false))
    }

    private func makeItemForPendingNonNFTAssetOptOutRequest(
        _ update: OptOutBlockchainUpdate
    ) -> IncomingAsaItem {
//        let item = AccountAssetsPendingAssetListItem(update: update)
//        return .pendingAsset(item)
        .empty(.init(hasBody: false))
    }

    private func makeItemsForPendingAssetSendRequests() -> [IncomingAsaItem] {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let updates = monitor.filterPendingSendPureCollectibleAssetUpdates(for: account.value)
        return updates.map {
            let update = $0.value
            return makeItemForPendingNFTAssetSendRequest(update)
        }
    }

    private func makeItemForPendingNFTAssetSendRequest(
        _ update: SendPureCollectibleAssetBlockchainUpdate
    ) -> IncomingAsaItem {
//        let item = AccountAssetsPendingCollectibleAssetListItem(update: update)
//        return .pendingCollectibleAsset(item)
        .empty(.init(hasBody: false))
    }

    private func makeItemsForAssets(query: AccountAssetListQuery?) -> [IncomingAsaItem] {
        let showsOnlyNonNFTAssets = query?.showsOnlyNonNFTAssets ?? false
        let assets = showsOnlyNonNFTAssets ? account.value.standardAssets : account.value.allAssets

        var assetItems: [IncomingAsaItem] = assets.someArray.compactMap {
            asset in
            if let query, !query.matches(asset) {
                return nil
            }

            /// <note>
            /// Pending asset requests has its own item different from the asset item.
            if hasAnyPendingAssetRequest(asset) {
                return nil
            }

            return makeItemForAsset(asset)
        }

        if let query, query.matchesByKeyword(account.value.algo) {
            let item = makeItemForAlgoAsset(account.value.algo)
            assetItems.insert(
                item,
                at: 0
            )
        }

        guard let sortingAlgorithm = query?.sortingAlgorithm else {
            return assetItems
        }

        return assetItems.sorted {
            return sortingAlgorithm.getFormula(
                asset: $0.asset!,
                otherAsset: $1.asset!
            )
        }
    }

    private func makeItemForAsset(_ asset: Asset) -> IncomingAsaItem? {
        switch asset {
        case let nonNFTAsset as StandardAsset: return makeItemForNonNFTAsset(nonNFTAsset)
        case let nftAsset as CollectibleAsset: return makeItemForNFTAsset(nftAsset)
        case let algoAsset as Algo: return makeItemForAlgoAsset(algoAsset)
        default: return nil
        }
    }

    private func makeItemForAlgoAsset(_ algoAsset: Algo) -> IncomingAsaItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: algoAsset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let item = IncomingAsaAssetListItem(item: assetItem)
        return .asset(item)
    }

    private func makeItemForNonNFTAsset(_ asset: StandardAsset) -> IncomingAsaItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let item = IncomingAsaAssetListItem(item: assetItem)
        return .asset(item)
    }

    private func makeItemForNFTAsset(_ asset: CollectibleAsset) -> IncomingAsaItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account.value,
            asset: asset,
            amountFormatter: assetAmountFormatter
        )
        let item = IncomingAsaCollectibleAssetListItem(item: collectibleAssetItem)
        return .collectibleAsset(item)
    }

    private func makeItemsForNotFound() -> [IncomingAsaItem] {
        let viewModel = AssetListSearchNoContentViewModel(hasBody: true)
        return [ .empty(viewModel) ]
    }
}

extension IncomingASAAccountInboxAPIDataController {
    private func hasAnyPendingAssetRequest(_ asset: Asset) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        let hasOptInRequest = monitor.hasPendingOptInRequest(
            assetID: asset.id,
            for: account.value
        )
        if hasOptInRequest {
            return true
        }

        let hasOptOutRequest = monitor.hasPendingOptOutRequest(
            assetID: asset.id,
            for: account.value
        )
        if hasOptOutRequest {
            return true
        }

        let hasSendRequest = monitor.hasPendingSendPureCollectibleAssetRequest(
            assetID: asset.id,
            for: account.value
        )
        if hasSendRequest {
            return true
        }

        return false
    }
}

extension IncomingASAAccountInboxAPIDataController {
    private func publish(updates: Updates) {
        lastSnapshot = updates.snapshot
        publish(event: .didUpdate(updates))
    }

    private func publish(event: IncomingAsaListDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event)
        }
    }
}

extension IncomingASAAccountInboxAPIDataController {
    private func createAsyncLoadingQueue() -> AsyncSerialQueue {
        let underlyingQueue = DispatchQueue(
            label: "pera.queue.accountAssets.updates",
            qos: .userInitiated
        )
        return .init(
            name: "accountAssetListAPIDataController.asyncLoadingQueue",
            underlyingQueue: underlyingQueue
        )
    }

    private func createSearchThrottler() -> Throttler {
        return .init(intervalInSeconds: 0.4)
    }

    private func createCurrencyFormatter() -> CurrencyFormatter {
        return .init()
    }

    private func createAssetAmountFormatter() -> CollectibleAmountFormatter {
        return .init()
    }

    private func createMinBalanceCalculator() -> TransactionFeeCalculator {
        return .init(transactionDraft: nil, transactionData: nil, params: nil)
    }
}

extension IncomingASAAccountInboxAPIDataController {
    typealias Updates = IncomingAsaListUpdates
    typealias Snapshot = IncomingAsaListUpdates.Snapshot
}
