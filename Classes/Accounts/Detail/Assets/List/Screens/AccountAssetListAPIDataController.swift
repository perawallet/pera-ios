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

    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var collectibleAmountFormatter = CollectibleAmountFormatter()
    private lazy var minimumBalanceCalculator = TransactionFeeCalculator(
        transactionDraft: nil,
        transactionData: nil,
        params: nil
    )
    private lazy var assetFilterOptions = AssetFilterOptions()

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.4)

    private var accountHandle: AccountHandle

    private var searchKeyword: String? = nil
    private var searchResults: [Asset] = []

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let updatesQueue = DispatchQueue(
        label: "pera.queue.accountAssets.updates",
        qos: .userInitiated
    )

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
}

extension AccountAssetListAPIDataController {
    func load() {
        sharedDataController.add(self)
    }

    func reload() {
        deliverContentUpdatesByLoading()
    }

    func reloadIfThereIsPendingUpdates() {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let account = accountHandle.value

        if monitor.hasAnyPendingOptInRequest(for: account) ||
           monitor.hasAnyPendingOptOutRequest(for: account) {
            deliverContentUpdates()
        }
    }
}

extension AccountAssetListAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case let .didStartRunning(first):
            if first || lastSnapshot == nil {
                deliverContentUpdatesByLoading()
            }
        case .didFinishRunning:
            if lastSnapshot == nil {
                deliverContentUpdatesByLoading()
                return
            }

            if let updatedAccountHandle = sharedDataController.accountCollection[accountHandle.value.address] {
                accountHandle = updatedAccountHandle
            }
            deliverContentUpdates()
        default:
            break
        }
    }
}

extension AccountAssetListAPIDataController {
    private func deliverContentUpdatesByLoading(
        searchQuery: String? = nil,
        isNewSearch: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        deliverUpdates {
            [unowned self] in

            var snapshot = Snapshot()

            self.addPortfolioSection(&snapshot)
            self.addQuickActionsSectionIfNeeded(&snapshot)
            self.addCommonAndLoadingAssetItems(&snapshot)

            /// <note>
            /// Asset items for search/filter/sort operations are handled after we send an update for the loading state.
            self.deliverUpdates {
                [unowned self] in
                self.addAssetItems(
                    searchQuery: searchQuery,
                    snapshot: &snapshot
                )
                snapshot.deleteItems(self.assetLoadingItems)

                let updates = Updates(snapshot: snapshot)
                return updates
            }

            var updates = Updates(snapshot: snapshot)
            updates.isNewSearch = isNewSearch
            updates.completion = completion
            return updates
        }
    }

    private func deliverContentUpdates() {
        deliverUpdates {
            [unowned self] in

            var snapshot = Snapshot()
            
            self.addPortfolioSection(&snapshot)
            self.addQuickActionsSectionIfNeeded(&snapshot)
            self.addAssetSection(
                searchQuery: self.searchKeyword,
                snapshot: &snapshot
            )
            
            return Updates(snapshot: snapshot)
        }
    }
    
    private func addPortfolioSection(_ snapshot: inout Snapshot) {
        let portfolioItem = makePortfolioItem(accountHandle)
        snapshot.appendSections([.portfolio])
        snapshot.appendItems(
            [ portfolioItem ],
            toSection: .portfolio
        )
    }
    
    private func addQuickActionsSectionIfNeeded(_ snapshot: inout Snapshot) {
        let isWatchAccount = accountHandle.value.isWatchAccount()
        if !isWatchAccount {
            snapshot.appendSections([.quickActions])
            snapshot.appendItems(
                [.quickActions],
                toSection: .quickActions
            )
        }
    }
    
    private func addCommonAndLoadingAssetItems(_ snapshot: inout Snapshot) {
        var assetItems = makeCommonAssetItems()
        let loadingItems = assetLoadingItems
        
        assetItems.append(contentsOf: loadingItems)
        
        snapshot.appendSections([.assets])
        snapshot.appendItems(
            assetItems,
            toSection: .assets
        )
    }
    
    private func makeCommonAssetItems() -> [AccountAssetsItem] {
        var assetItems: [AccountAssetsItem] = []
        let titleItem = makeTitleItem(accountHandle.value)
        assetItems.append(titleItem)

        assetItems.append(.search)
        
        return assetItems
    }
    
    var assetLoadingItems: [AccountAssetsItem] {
        return [
            .assetLoading("1"),
            .assetLoading("2"),
            .assetLoading("3")
        ]
    }
    
    private func addAssetItems(
        searchQuery: String?,
        snapshot: inout Snapshot
    ) {
        let assetItems = makeAssetItems(searchQuery: searchQuery)

        snapshot.appendItems(
            assetItems,
            toSection: .assets
        )
        
        let shouldShowEmptyContent = assetItems.isEmpty
        if shouldShowEmptyContent {
            addEmptySection(&snapshot)
        }
    }
    
    private func addAssetSection(
        searchQuery: String?,
        snapshot: inout Snapshot
    ) {
        var items = makeCommonAssetItems()
        let assetItems = makeAssetItems(searchQuery: searchQuery)
        
        items.append(contentsOf: assetItems)

        snapshot.appendSections([.assets])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
        
        let shouldShowEmptyContent = assetItems.isEmpty
        if shouldShowEmptyContent {
            addEmptySection(&snapshot)
        }
    }

    private func makeAssetItems(searchQuery: String? = nil) -> [AccountAssetsItem] {
        var assetItems: [AccountAssetsItem] = []
        
        let pendingItems = makePendingAssetListItems(accountHandle.value)
        assetItems.append(contentsOf: pendingItems)

        let assetListItems = makeAssetListItems(
            searchQuery: searchQuery,
            account: accountHandle
        )
        assetItems.append(contentsOf: assetListItems)

        return assetItems
    }
    
    private func addEmptySection(_ snapshot: inout Snapshot) {
        let searchNoContentItem = self.makeSearchNoContentItem()
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [ searchNoContentItem ],
            toSection: .empty
        )
    }

    private func deliverUpdates(
        updates: @escaping () -> Updates?
    ) {
        updatesQueue.async {
            [weak self] in
            guard let self = self else { return }

            guard let updates = updates() else { return }

            self.lastSnapshot = updates.snapshot
            self.publish(event: .didUpdate(updates))
        }
    }
}

extension AccountAssetListAPIDataController {
    private func makePendingAssetListItems(_ account: Account) -> [AccountAssetsItem] {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        let pendingOptInAssets = monitor.filterPendingOptInAssetUpdates(for: account)
        let pendingOptInAssetListItems = pendingOptInAssets.map { pendingOptInAsset in
            let update = pendingOptInAsset.value

            if update.isCollectibleAsset {
                return makePendingCollectibleAssetOptInListItem(update)
            } else {
                return makePendingOptInAssetListItem(update)
            }
        }

        let pendingOptOutAssets = monitor.filterPendingOptOutAssetUpdates(for: account)
        let pendingOptOutAssetListItems = pendingOptOutAssets.map { pendingOptOutAsset in
            let update = pendingOptOutAsset.value

            if update.isCollectibleAsset {
                return makePendingCollectibleAssetOptOutListItem(update)
            } else {
                return makePendingOptOutAssetListItem(update)
            }
        }

        let pendingSendPureCollectibleAssets = monitor.filterPendingSendPureCollectibleAssetUpdates(for: account)
        let pendingSendPureCollectibleAssetListItems = pendingSendPureCollectibleAssets.map { pendingSendPureCollectibleAsset in
            let update = pendingSendPureCollectibleAsset.value

            return makePendingPureCollectibleAssetSendListItem(update)
        }

        return pendingOptInAssetListItems + pendingOptOutAssetListItems + pendingSendPureCollectibleAssetListItems
    }

    private func makeAssetListItems(
        searchQuery: String?,
        account: AccountHandle
    ) -> [AccountAssetsItem] {
        load(with: searchQuery)

        let account = accountHandle.value

        var assetListItems: [AccountAssetsItem] = []

        if isKeywordContainsAlgo() {
            assetListItems.append(makeAssetListItem(account.algo))
        }

        searchResults.forEach { asset in
            /// <note>
            /// Since we are showing separate pending item for pending opt out, we should filter asset according to.
            let hasPendingOptOut = hasPendingOptOutRequest(
                asset: asset,
                account: account
            )
            if hasPendingOptOut {
                return
            }
            /// <note>
            /// Since we are showing separate pending item for pending send pure collectible asset, we should filter collectible asset according to.
            let hasPendingSendPureCollectibleAsset = hasPendingSendPureCollectibleAssetRequest(
                assetID: asset.id,
                account: account
            )
            if hasPendingSendPureCollectibleAsset {
                return
            }

            if !shouldDisplayOptedInCollectibleAsset(asset) {
                return
            }

            if shouldHideAssetWithNoBalance(asset) {
                return
            }

            if let standardAsset = asset as? StandardAsset {
                assetListItems.append(makeAssetListItem(standardAsset))
            }

            if let collectibleAsset = asset as? CollectibleAsset {
                assetListItems.append(
                    makeCollectibleAssetListItem(
                        asset: collectibleAsset,
                        account: account
                    )
                )
            }
        }

        if let selectedAccountAssetSortingAlgorithm = sharedDataController.selectedAccountAssetSortingAlgorithm {
            assetListItems.sort { assetListItem, otherAssetListItem in
                return selectedAccountAssetSortingAlgorithm.getFormula(
                    asset: assetListItem.asset!,
                    otherAsset: otherAssetListItem.asset!
                )
            }
        }

        return assetListItems
    }
}

extension AccountAssetListAPIDataController {
    private func makePortfolioItem(_ accountHandle: AccountHandle) -> AccountAssetsItem {
        let currency = sharedDataController.currency

        let aRawAccount = accountHandle.value
        let isWatchAccount = aRawAccount.isWatchAccount()

        if isWatchAccount {
            let portfolio = AccountPortfolioItem(
                accountValue: accountHandle,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
            let viewModel = WatchAccountPortfolioViewModel(portfolio)
            return .watchPortfolio(viewModel)
        } else {
            let calculatedMinimumBalance =
            self.minimumBalanceCalculator
                .calculateMinimumAmount(
                    for: aRawAccount,
                    with: .algosTransaction,
                    calculatedFee: .zero,
                    isAfterTransaction: false
                )
            let portfolio = AccountPortfolioItem(
                accountValue: accountHandle,
                currency: currency,
                currencyFormatter: currencyFormatter,
                minimumBalance: calculatedMinimumBalance
            )
            let viewModel = AccountPortfolioViewModel(portfolio)
            return .portfolio(viewModel)
        }
    }

    private func makeTitleItem(_ account: Account) -> AccountAssetsItem {
        let isWatchAccount = account.isWatchAccount()

        if isWatchAccount {
            return .watchAccountAssetManagement(
                ManagementItemViewModel(
                    .asset(
                        isWatchAccountDisplay: true
                    )
                )
            )
        } else {
            return .assetManagement(
                ManagementItemViewModel(
                    .asset(
                        isWatchAccountDisplay: false
                    )
                )
            )
        }
    }

    private func makeSearchNoContentItem() -> AccountAssetsItem {
        return .empty(AssetListSearchNoContentViewModel(hasBody: true))
    }

    private func makeAssetListItem(_ asset: Asset) -> AccountAssetsItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let listItem = AccountAssetsAssetListItem(item: assetItem)
        return .asset(listItem)
    }

    private func makePendingOptInAssetListItem(_ update: OptInBlockchainUpdate) -> AccountAssetsItem {
        let listItem = AccountAssetsPendingAssetListItem(update: update)
        return .pendingAsset(listItem)
    }

    private func makePendingOptOutAssetListItem(_ update: OptOutBlockchainUpdate) -> AccountAssetsItem {
        let listItem = AccountAssetsPendingAssetListItem(update: update)
        return .pendingAsset(listItem)
    }

    private func makeCollectibleAssetListItem(
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
    private func shouldDisplayOptedInCollectibleAsset(_ asset: Asset) -> Bool {
        guard let asset = asset as? CollectibleAsset,
              !asset.isOwned else {
            return true
        }

        return assetFilterOptions.displayOptedInCollectibleAssetsInAssetList
    }

    private func shouldHideAssetWithNoBalance(_ asset: Asset) -> Bool {
        if asset.amount != .zero {
            return false
        }

        if asset.isAlgo {
            return false
        }

        if asset is CollectibleAsset {
            return false
        }

        return assetFilterOptions.hideAssetsWithNoBalanceInAssetList
    }
}

extension AccountAssetListAPIDataController {
    private func publish(
        event: AccountAssetListDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event)
        }
    }
}

/// <mark>: Search
extension AccountAssetListAPIDataController {
    func search(
        for query: String?,
        completion: @escaping () -> Void
    ) {
        searchThrottler.performNext {
            [weak self] in
            guard let self = self else { return }

            self.deliverContentUpdatesByLoading(
                searchQuery: query,
                isNewSearch: true,
                completion: completion
            )
        }
    }

    private func load(with query: String?) {
        if query.isNilOrEmpty {
            searchKeyword = nil
        } else {
            searchKeyword = query
        }

        let assets: [Asset]

        let account = accountHandle.value

        if assetFilterOptions.displayCollectibleAssetsInAssetList {
            assets = account.allAssets.someArray
        } else {
            assets = account.standardAssets.someArray
        }

        guard let searchKeyword = searchKeyword else {
            searchResults = assets
            return
        }

        searchResults = assets.filter { asset in
            isAssetContainsID(asset, query: searchKeyword) ||
            isAssetContainsName(asset, query: searchKeyword) ||
            isAssetContainsUnitName(asset, query: searchKeyword)
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

    private func isKeywordContainsAlgo() -> Bool {
        guard let keyword = searchKeyword, !keyword.isEmptyOrBlank else {
            /// <note>: If keyword doesn't contain any word or it's empty, it should return true for adding algo to asset list
            return true
        }

        return "algo".containsCaseInsensitive(keyword)
    }
}

extension AccountAssetListAPIDataController {
    typealias Updates = AccountAssetListUpdates
    typealias Snapshot = AccountAssetListUpdates.Snapshot
}
