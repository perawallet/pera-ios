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
        deliverContentUpdates()
    }

    func reloadIfThereIsPendingUpdates() {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let account = accountHandle.value

        if monitor.hasAnyPendingOptInRequest(for: account) ||
           monitor.hasAnyPendingOptOutRequest(for: account) {
            reload()
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
            if first ||
               lastSnapshot == nil {
                deliverContentUpdates()
            }
        case .didFinishRunning:
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
    private func deliverContentUpdates(
        isNewSearch: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        deliverUpdates {
            [weak self] in
            guard let self = self else { return nil }

            var snapshot = Snapshot()

            let portfolioItem = self.makePortfolioItem()
            snapshot.appendSections([.portfolio])
            snapshot.appendItems(
                [ portfolioItem ],
                toSection: .portfolio
            )

            let isWatchAccount = self.accountHandle.value.isWatchAccount()
            if !isWatchAccount {
                snapshot.appendSections([.quickActions])
                snapshot.appendItems(
                    [.quickActions],
                    toSection: .quickActions
                )
            }

            var assetItems: [AccountAssetsItem] = []

            let titleItem = self.makeTitleItem()
            assetItems.append(titleItem)

            assetItems.append(.search)

            let pendingItems = self.makePendingAssetListItems()
            assetItems.append(contentsOf: pendingItems)

            let assetListItems = self.makeAssetListItems()
            assetItems.append(contentsOf: assetListItems)

            snapshot.appendSections([.assets])
            snapshot.appendItems(
                assetItems,
                toSection: .assets
            )

            let shouldShowEmptyContent = pendingItems.isEmpty && assetListItems.isEmpty
            if shouldShowEmptyContent {
                let searchNoContentItem = self.makeSearchNoContentItem()
                snapshot.appendSections([.empty])
                snapshot.appendItems(
                    [ searchNoContentItem ],
                    toSection: .empty
                )
            }

            var updates = Updates(snapshot: snapshot)
            updates.isNewSearch = isNewSearch
            updates.completion = completion
            return updates
        }
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
    private func makePendingAssetListItems() -> [AccountAssetsItem] {
        let account = accountHandle.value
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

    private func makeAssetListItems() -> [AccountAssetsItem] {
        load(with: searchKeyword)

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
                assetListItems.append(makeCollectibleAssetListItem(collectibleAsset))
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
    private func makePortfolioItem() -> AccountAssetsItem {
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

    private func makeTitleItem() -> AccountAssetsItem {
        let isWatchAccount = accountHandle.value.isWatchAccount()

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

    private func makeCollectibleAssetListItem(_ asset: CollectibleAsset) -> AccountAssetsItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: accountHandle.value,
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

            self.load(with: query)
            self.deliverContentUpdates(
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

        if assetFilterOptions.displayCollectibleAssetsInAssetList {
            assets = accountHandle.value.allAssets.someArray
        } else {
            assets = accountHandle.value.standardAssets.someArray
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
