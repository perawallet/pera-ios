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

    private var accountHandle: AccountHandle

    private var searchKeyword: String? = nil
    private var searchResults: [Asset] = []

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let updatesQueue = DispatchQueue(label: "com.algorand.queue.accountAssetListDataController")

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
}

extension AccountAssetListAPIDataController {
    func load() {
        sharedDataController.add(self)
    }

    func reload() {
        deliverContentUpdates()
    }
    
    func updateFilterSelection(with newSelection: AssetsFilteringOption) {
        sharedDataController.selectedAssetsFilteringOption = newSelection
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

            let account = self.accountHandle.value
            let monitor = self.sharedDataController.blockchainUpdatesMonitor

            var pendingItems: [AccountAssetsItem] = []

            let pendingOptInAssets = monitor.filterPendingOptInAssetUpdates(for: account)
            for pendingOptInAsset in pendingOptInAssets {
                let update = pendingOptInAsset.value

                if update.isCollectibleAsset {
                    pendingItems.append(self.makePendingCollectibleAssetOptInListItem(update))
                    continue
                }

                let assetItem = self.makePendingOptInAssetListItem(update)
                pendingItems.append(assetItem)
            }

            let pendingOptOutAssets = monitor.filterPendingOptOutAssetUpdates(for: account)
            for pendingOptOutAsset in pendingOptOutAssets {
                let update = pendingOptOutAsset.value

                if update.isCollectibleAsset {
                    pendingItems.append(self.makePendingCollectibleAssetOptOutListItem(update))
                    continue
                }

                let assetItem = self.makePendingOptOutAssetListItem(update)
                pendingItems.append(assetItem)
            }

            assetItems.append(contentsOf: pendingItems)

            self.load(with: self.searchKeyword)

            var assetListItems: [AccountAssetsItem] = []

            if self.isKeywordContainsAlgo() {
                let algoAssetListItem = self.makeAssetListItem(self.accountHandle.value.algo)
                assetListItems.append(algoAssetListItem)
            }

            self.searchResults.forEach { asset in
                let hasPendingOptOut = monitor.hasPendingOptOutRequest(
                    assetID: asset.id,
                    for: account
                )
                if hasPendingOptOut {
                    return
                }
                
                if self.sharedDataController.selectedAssetsFilteringOption == .hideZeroBalance,
                   !asset.isAlgo,
                   asset.amount == 0 {
                    return
                }

                if let standardAsset = asset as? StandardAsset {
                    let assetItem = self.makeAssetListItem(standardAsset)
                    assetListItems.append(assetItem)
                    return
                }

                if let collectibleAsset = asset as? CollectibleAsset {
                    assetListItems.append(self.makeCollectibleAssetListItem(collectibleAsset))
                    return
                }
            }

            if let selectedAccountAssetSortingAlgorithm = self.sharedDataController.selectedAccountAssetSortingAlgorithm {
                assetListItems.sort { assetListItem, otherAssetListItem in
                    let asset = assetListItem.asset!
                    let otherAsset = otherAssetListItem.asset!

                    return selectedAccountAssetSortingAlgorithm.getFormula(
                        asset: asset,
                        otherAsset: otherAsset
                    )
                }
            }

            assetItems.append(contentsOf: assetListItems)

            snapshot.appendSections([.assets])
            snapshot.appendItems(
                assetItems,
                toSection: .assets
            )

            let shouldShowEmptyContent =
                !self.isKeywordContainsAlgo() &&
                pendingItems.isEmpty &&
                self.searchResults.isEmpty

            if shouldShowEmptyContent {
                snapshot.appendSections([.empty])

                snapshot.appendItems(
                    [ .empty(AssetListSearchNoContentViewModel(hasBody: true)) ],
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

            guard let updates = updates() else {
                return
            }

            self.lastSnapshot = updates.snapshot
            self.publish(event: .didUpdate(updates))
        }
    }
}

extension AccountAssetListAPIDataController {
    private func makePortfolioItem() -> AccountAssetsItem {
        let currency = sharedDataController.currency

        let isWatchAccount = accountHandle.value.isWatchAccount()

        if isWatchAccount {
                let portfolio = AccountPortfolioItem(
                    accountValue: self.accountHandle,
                    currency: currency,
                    currencyFormatter: currencyFormatter
                )
                let viewModel = WatchAccountPortfolioViewModel(portfolio)
                return .watchPortfolio(viewModel)
            } else {
                let calculatedMinimumBalance =
                    self.minimumBalanceCalculator
                        .calculateMinimumAmount(
                            for: self.accountHandle.value,
                            with: .algosTransaction,
                            calculatedFee: .zero,
                            isAfterTransaction: false
                        )
                let portfolio = AccountPortfolioItem(
                    accountValue: self.accountHandle,
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

        guard let searchKeyword = searchKeyword else {
            searchResults = accountHandle.value.allAssets.someArray
            return
        }

        searchResults = accountHandle.value.allAssets.someArray.filter { asset in
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
