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

    private(set) var account: AccountHandle

    private lazy var currencyFormatter: CurrencyFormatter = .init()
    private lazy var collectibleAmountFormatter: CollectibleAmountFormatter = .init()
    private lazy var minimumBalanceCalculator = TransactionFeeCalculator(
        transactionDraft: nil,
        transactionData: nil,
        params: nil
    )

    private lazy var asyncLoadingQueue = createAsyncLoadingQueue()
    private lazy var searchThrottler: Throttler = .init(intervalInSeconds: 0.4)

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
        sharedDataController.remove(self)
    }
}

extension AccountAssetListAPIDataController {
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
        } else {
            search(query: query)
        }
    }

    private func customize(query: AccountAssetListQuery?) {
        searchThrottler.cancelAll()
        asyncLoadingQueue.cancel()

        deliverUpdatesForLoading(operation: .customize)

        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            let updates = self.makeUpdates(
                query: query,
                for: .customize
            )

            if query != self.nextQuery { return }

            self.lastQuery = query
            self.nextQuery = nil
            self.publish(updates: updates)
        }
        asyncLoadingQueue.add(task)
        asyncLoadingQueue.resume()
    }

    private func search(query: AccountAssetListQuery?) {
        asyncLoadingQueue.cancel()

        deliverUpdatesForLoading(operation: .search)

        searchThrottler.performNext {
            [weak self] in
            guard let self else { return }

            let task = AsyncTask {
                [weak self] completionBlock in
                guard let self else { return }

                defer {
                    completionBlock()
                }

                let updates = self.makeUpdates(
                    query: query,
                    for: .search
                )

                if query != self.nextQuery { return }

                self.lastQuery = query
                self.nextQuery = nil
                self.publish(updates: updates)
            }
            self.asyncLoadingQueue.add(task)
            self.asyncLoadingQueue.resume()
        }
    }

    private func loadFirst(query: AccountAssetListQuery?) {
        deliverUpdatesForLoading(operation: .customize)

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

    private func reload() {
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            let updates = self.makeUpdates(
                query: self.lastQuery,
                for: .refresh
            )

            if self.nextQuery != nil { return }

            self.publish(updates: updates)
        }
        asyncLoadingQueue.add(task)
    }
}

extension AccountAssetListAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            canDeliverUpdatesForAssets = true

            if let updatedAccount = sharedDataController.accountCollection[account.value.address] {
                account = updatedAccount
                reload()
            }
        }
    }
}

extension AccountAssetListAPIDataController {
    private func deliverUpdatesForLoading(operation: Updates.Operation) {
        if lastSnapshot?.itemIdentifiers(inSection: .assets).last == .assetLoading {
            return
        }

        var snapshot = Snapshot()
        appendPortfolioSections(into: &snapshot)
        appendQuickActionsSectionsIfNeeded(into: &snapshot)
        appendAssetsLoadingSections(into: &snapshot)

        let updates = Updates(snapshot: snapshot, operation: operation)

        publish(updates: updates)
    }

    private func makeUpdates(
        query: AccountAssetListQuery?,
        for operation: Updates.Operation
    ) -> Updates {
        var snapshot = Snapshot()
        appendPortfolioSections(into: &snapshot)
        appendQuickActionsSectionsIfNeeded(into: &snapshot)
        appendAssetsSections(
            query: query,
            into: &snapshot
        )
        return Updates(snapshot: snapshot, operation: operation)
    }
}

extension AccountAssetListAPIDataController {
    private func appendPortfolioSections(into snapshot: inout Snapshot) {
        let items = makePortfolioItems()
        snapshot.appendSections([ .portfolio ])
        snapshot.appendItems(
            items,
            toSection: .portfolio
        )
    }

    private func appendQuickActionsSectionsIfNeeded(into snapshot: inout Snapshot) {
        let items = makeQuickActionsItems()

        if items.isEmpty { return }

        snapshot.appendSections([ .quickActions ])
        snapshot.appendItems(
            items,
            toSection: .quickActions
        )
    }

    private func appendAssetsLoadingSections(into snapshot: inout Snapshot) {
        let items = makeAssetListHeaderItems() + makeAssetListLoadingItems()
        snapshot.appendSections([ .assets ])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
    }

    private func appendAssetsSections(
        query: AccountAssetListQuery?,
        into snapshot: inout Snapshot
    ) {
        let assetListItems = makePendingAssetListItems() + makeAssetListItems(query: query)
        let items = makeAssetListHeaderItems() + assetListItems

        snapshot.appendSections([ .assets ])
        snapshot.appendItems(
            items,
            toSection: .assets
        )

        if assetListItems.isEmpty {
            appendSectionsForNotFound(into: &snapshot)
        }
    }

    private func appendSectionsForNotFound(into snapshot: inout Snapshot) {
        let items = makeNotFoundListItems()

        snapshot.appendSections([.empty])
        snapshot.appendItems(
            items,
            toSection: .empty
        )
    }
}

extension AccountAssetListAPIDataController {
    private func makePortfolioItems() -> [AccountAssetsItem] {
        if account.value.isWatchAccount() {
            return makeWatchAccountPortfolioItems()
        } else {
            return makeNormalAccountPortfolioItems()
        }
    }

    private func makeWatchAccountPortfolioItems() -> [AccountAssetsItem] {
        let currency = sharedDataController.currency
        let portfolio = AccountPortfolioItem(
            accountValue: account,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let viewModel = WatchAccountPortfolioViewModel(portfolio)
        return [ .watchPortfolio(viewModel) ]
    }

    private func makeNormalAccountPortfolioItems() -> [AccountAssetsItem] {
        let currency = sharedDataController.currency
        let calculatedMinimumBalance = minimumBalanceCalculator.calculateMinimumAmount(
            for: account.value,
            with: .algosTransaction,
            calculatedFee: .zero,
            isAfterTransaction: false
        )
        let portfolio = AccountPortfolioItem(
            accountValue: account,
            currency: currency,
            currencyFormatter: currencyFormatter,
            minimumBalance: calculatedMinimumBalance
        )
        let viewModel = AccountPortfolioViewModel(portfolio)
        return [ .portfolio(viewModel) ]
    }

    private func makeQuickActionsItems() -> [AccountAssetsItem] {
        if account.value.isWatchAccount() {
            return []
        } else {
            return [ .quickActions ]
        }
    }

    private func makeAssetListHeaderItems() -> [AccountAssetsItem] {
        let titleItems = account.value.isWatchAccount()
            ? makeWatchAccountAssetListTitleItems()
            : makeNormalAccountAssetListTitleItems()
        return titleItems + [ .search ]
    }

    private func makeWatchAccountAssetListTitleItems() -> [AccountAssetsItem] {
        let item = ManagementItemViewModel(.asset(isWatchAccountDisplay: true))
        return [ .watchAccountAssetManagement(item) ]
    }

    private func makeNormalAccountAssetListTitleItems() -> [AccountAssetsItem] {
        let item = ManagementItemViewModel(.asset(isWatchAccountDisplay: false))
        return [ .assetManagement(item) ]
    }

    private func makeAssetListLoadingItems() -> [AccountAssetsItem] {
        return [ .assetLoading ]
    }

    private func makePendingAssetListItems() -> [AccountAssetsItem] {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        let pendingOptInAssets = monitor.filterPendingOptInAssetUpdates(for: account.value)
        let pendingOptInAssetListItems = pendingOptInAssets.map { pendingOptInAsset in
            let update = pendingOptInAsset.value

            if update.isCollectibleAsset {
                return makePendingCollectibleAssetOptInListItem(update)
            } else {
                return makePendingOptInAssetListItem(update)
            }
        }

        let pendingOptOutAssets = monitor.filterPendingOptOutAssetUpdates(for: account.value)
        let pendingOptOutAssetListItems = pendingOptOutAssets.map { pendingOptOutAsset in
            let update = pendingOptOutAsset.value

            if update.isCollectibleAsset {
                return makePendingCollectibleAssetOptOutListItem(update)
            } else {
                return makePendingOptOutAssetListItem(update)
            }
        }

        let pendingSendPureCollectibleAssets = monitor.filterPendingSendPureCollectibleAssetUpdates(for: account.value)
        let pendingSendPureCollectibleAssetListItems = pendingSendPureCollectibleAssets.map { pendingSendPureCollectibleAsset in
            let update = pendingSendPureCollectibleAsset.value

            return makePendingPureCollectibleAssetSendListItem(update)
        }

        return pendingOptInAssetListItems + pendingOptOutAssetListItems + pendingSendPureCollectibleAssetListItems
    }

    private func makePendingOptInAssetListItem(_ update: OptInBlockchainUpdate) -> AccountAssetsItem {
        let listItem = AccountAssetsPendingAssetListItem(update: update)
        return .pendingAsset(listItem)
    }

    private func makePendingOptOutAssetListItem(_ update: OptOutBlockchainUpdate) -> AccountAssetsItem {
        let listItem = AccountAssetsPendingAssetListItem(update: update)
        return .pendingAsset(listItem)
    }

    private func makePendingCollectibleAssetOptInListItem(_ update: OptInBlockchainUpdate) -> AccountAssetsItem {
        let listItem = AccountAssetsPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(listItem)
    }

    private func makePendingCollectibleAssetOptOutListItem(_ update: OptOutBlockchainUpdate) -> AccountAssetsItem {
        let item = AccountAssetsPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(item)
    }

    private func makePendingPureCollectibleAssetSendListItem(_ update: SendPureCollectibleAssetBlockchainUpdate) -> AccountAssetsItem {
        let item = AccountAssetsPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(item)
    }

    private func makeAssetListItems(query: AccountAssetListQuery?) -> [AccountAssetsItem] {
        let showsOnlyNonNFTAssets = query?.showsOnlyNonNFTAssets ?? false
        let assets = showsOnlyNonNFTAssets ? account.value.standardAssets : account.value.allAssets
        let optedInAssetListItems: [AccountAssetsItem] = assets.someArray.compactMap {
            asset in
            if let keyword = (query?.keyword).unwrapNonEmptyString() {
                if !isAssetContainsID(asset, query: keyword) &&
                   !isAssetContainsName(asset, query: keyword) &&
                   !isAssetContainsUnitName(asset, query: keyword) {
                    return nil
                }
            }

            /// <note>
            /// Since we are showing separate pending item for pending opt out, we should filter asset according to.
            let hasPendingOptOut = hasPendingOptOutRequest(
                asset: asset,
                account: account.value
            )
            if hasPendingOptOut {
                return nil
            }
            /// <note>
            /// Since we are showing separate pending item for pending send pure collectible asset, we should filter collectible asset according to.
            let hasPendingSendPureCollectibleAsset = hasPendingSendPureCollectibleAssetRequest(
                assetID: asset.id,
                account: account.value
            )
            if hasPendingSendPureCollectibleAsset {
                return nil
            }

            if !shouldDisplayOptedInCollectibleAsset(asset, query: query) {
                return nil
            }

            if shouldHideAssetWithNoBalance(asset, query: query) {
                return nil
            }

            if let standardAsset = asset as? StandardAsset {
                return makeNonNFTAssetListItem(standardAsset)
            }

            if let collectibleAsset = asset as? CollectibleAsset {
                return makeNFTAssetListItem(
                    asset: collectibleAsset,
                    account: account.value
                )
            }

            return nil
        }

        var assetListItems: [AccountAssetsItem] = []
        if isKeywordContainsAlgo(query: query) {
            let algoAssetListItem = makeAlgoAssetListItem(account.value.algo)
            assetListItems = [algoAssetListItem] + optedInAssetListItems
        } else {
            assetListItems = optedInAssetListItems
        }

        guard let sortingAlgorithm = query?.sortingAlgorithm else {
            return assetListItems
        }

        return assetListItems.sorted {
            return sortingAlgorithm.getFormula(
                asset: $0.asset!,
                otherAsset: $1.asset!
            )
        }
    }

    private func makeAlgoAssetListItem(_ algoAsset: Algo) -> AccountAssetsItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: algoAsset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let item = AccountAssetsAssetListItem(item: assetItem)
        return .asset(item)
    }

    private func makeNonNFTAssetListItem(_ asset: Asset) -> AccountAssetsItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let item = AccountAssetsAssetListItem(item: assetItem)
        return .asset(item)
    }

    private func makeNFTAssetListItem(
        asset: CollectibleAsset,
        account: Account
    ) -> AccountAssetsItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let listItem = AccountAssetsCollectibleAssetListItem(item: collectibleAssetItem)
        return .collectibleAsset(listItem)
    }

    private func makeNotFoundListItems() -> [AccountAssetsItem] {
        let viewModel = AssetListSearchNoContentViewModel(hasBody: true)
        return [ .empty(viewModel) ]
    }
}

extension AccountAssetListAPIDataController {
    private func hasPendingOptOutRequest(
        asset: Asset,
        account: Account
    ) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        return monitor.hasPendingOptOutRequest(
            assetID: asset.id,
            for: account
        )
    }

    private func hasPendingSendPureCollectibleAssetRequest(
        assetID: AssetID,
        account: Account
    ) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        return monitor.hasPendingSendPureCollectibleAssetRequest(
            assetID: assetID,
            for: account
        )
    }
}

extension AccountAssetListAPIDataController {
    private func shouldDisplayOptedInCollectibleAsset(
        _ asset: Asset,
        query: AccountAssetListQuery?
    ) -> Bool {
        guard let query else {
            return true
        }

        guard let asset = asset as? CollectibleAsset,
              !asset.isOwned else {
            return true
        }

        return !query.showsOnlyOwnedNFTAssets
    }

    private func shouldHideAssetWithNoBalance(
        _ asset: Asset,
        query: AccountAssetListQuery?
    ) -> Bool {
        guard let query else {
            return false
        }

        if asset.amount != .zero {
            return false
        }

        if asset.isAlgo {
            return false
        }

        if asset is CollectibleAsset {
            return false
        }

        return query.showsOnlyOwnedNonNFTAssets
    }
}

extension AccountAssetListAPIDataController {
    private func publish(updates: Updates) {
        lastSnapshot = updates.snapshot
        publish(event: .didUpdate(updates))
    }

    private func publish(event: AccountAssetListDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event)
        }
    }
}

/// <mark>: Search
extension AccountAssetListAPIDataController {
    private func isAssetContainsID(_ asset: Asset, query: String) -> Bool {
        return String(asset.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(_ asset: Asset, query: String) -> Bool {
        return asset.naming.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(_ asset: Asset, query: String) -> Bool {
        return asset.naming.unitName.someString.localizedCaseInsensitiveContains(query)
    }

    private func isKeywordContainsAlgo(query: AccountAssetListQuery?) -> Bool {
        /// <note>
        /// If keyword doesn't contain any word or it's empty, it should return true for adding algo
        /// to asset list
        if let keyword = (query?.keyword).unwrapNonEmptyString() {
            return "algo".containsCaseInsensitive(keyword)
        } else {
            return true
        }
    }
}

extension AccountAssetListAPIDataController {
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
}

extension AccountAssetListAPIDataController {
    typealias Updates = AccountAssetListUpdates
    typealias Snapshot = AccountAssetListUpdates.Snapshot
}
