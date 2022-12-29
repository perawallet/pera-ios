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

//   CollectibleListLocalDataController.swift

import Foundation
import CoreGraphics
import MacaroonUtils

/// <todo> Separate the data controllers (Account Detail Collectibles & Collectibles).
final class CollectibleListLocalDataController:
    CollectibleListDataController,
    SharedDataControllerObserver,
    NotificationObserver {
    static var didAddCollectible: Notification.Name {
        return .init(rawValue: Constants.Notification.collectibleListDidAddCollectible)
    }
    static var didRemoveCollectible: Notification.Name {
        return .init(rawValue: Constants.Notification.collectibleListDidRemoveCollectible)
    }
    static var didSendCollectible: Notification.Name {
        return .init(rawValue: Constants.Notification.collectibleListDidSendCollectible)
    }

    var notificationObservations: [NSObjectProtocol] = []

    var eventHandler: ((CollectibleDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?

    private lazy var collectibleAmountFormatter: CollectibleAmountFormatter = .init()
    private lazy var collectibleFilterOptions: CollectibleFilterOptions = .init()
    private lazy var collectibleGalleryUIStyleStore: CollectibleGalleryUIStyleStore = .init()

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.collectibles.updates",
        qos: .userInitiated
    )

    let galleryAccount: CollectibleGalleryAccount

    private var accounts: AccountCollection = []
    private let sharedDataController: SharedDataController

    private let isWatchAccount: Bool

    var imageSize: CGSize = .zero

    private var lastQuery: String?

    init(
        galleryAccount: CollectibleGalleryAccount,
        sharedDataController: SharedDataController
    ) {
        self.galleryAccount = galleryAccount
        self.sharedDataController = sharedDataController

        self.isWatchAccount = galleryAccount.singleAccount?.value.isWatchAccount() ?? false

        self.startObservingCollectibleAssetActions()
    }

    deinit {
        sharedDataController.remove(self)
        stopObservingNotifications()
    }
}

extension CollectibleListLocalDataController {
    private func startObservingCollectibleAssetActions() {
        observe(notification: Self.didAddCollectible) {
            [weak self] _ in
            guard let self else { return }
            self.reload()
        }
        observe(notification: Self.didRemoveCollectible) {
            [weak self] _ in
            guard let self else { return }
            self.reload()
        }
        observe(notification: Self.didSendCollectible) {
            [weak self] _ in
            guard let self else { return }
            self.reload()
        }
    }
}

extension CollectibleListLocalDataController {
    func load() {
        sharedDataController.add(self)
    }

    func reload() {
        deliverContentSnapshot(with: lastQuery)
    }

    func search(for query: String) {
        searchThrottler.performNext {
            [weak self] in
            guard let self = self else { return }

            self.deliverContentSnapshot(with: query)
        }
    }

    func resetSearch() {
        searchThrottler.cancelAll()

        deliverContentSnapshot()
    }
}

extension CollectibleListLocalDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didBecomeIdle:
            deliverInitialSnapshot()
        case .didStartRunning(let isFirst):
            if isFirst ||
                lastSnapshot == nil {
                deliverInitialSnapshot()
            }
        case .didFinishRunning:
            switch galleryAccount {
            case .single(let account):
                guard let updatedAccount = sharedDataController.accountCollection[account.value.address] else {
                    return
                }

                if lastSnapshot == nil {
                    deliverInitialSnapshot()
                }

                if case .failed = updatedAccount.status {
                    eventHandler?(.didFinishRunning(hasError: true))
                    return
                }

                eventHandler?(.didFinishRunning(hasError: false))

                accounts = [updatedAccount]

                deliverContentSnapshot(with: lastQuery)
            case .all:
                let accounts = sharedDataController.accountCollection

                if lastSnapshot == nil {
                    deliverInitialSnapshot()
                }

                for account in accounts {
                    if case .failed = account.status {
                        eventHandler?(.didFinishRunning(hasError: true))
                        return
                    }
                }

                eventHandler?(.didFinishRunning(hasError: false))

                self.accounts = accounts

                deliverContentSnapshot(with: lastQuery)
            }
        }
    }
}

extension CollectibleListLocalDataController {
    private func deliverInitialSnapshot() {
        if sharedDataController.isPollingAvailable {
            deliverLoadingSnapshot()
        } else {
            deliverNoContentSnapshot()
        }
    }

    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])
            snapshot.appendItems(
                [.empty(.loading)],
                toSection: .loading
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot(
        with query: String? = nil
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self else { return Snapshot() }
            self.lastQuery = query

            var hiddenCollectibleCount = 0

            let pendingCollectibleItems = self.makePendingCollectibleListItems()
            let collectibleItems = self.makeCollectibleListItems(
                query: query,
                hiddenCollectibleCount: &hiddenCollectibleCount
            )

            let shouldShowEmptyContent = collectibleItems.isEmpty && pendingCollectibleItems.isEmpty

            if shouldShowEmptyContent {
                let isSearching = self.lastQuery != nil

                if isSearching {
                    self.deliverSearchNoContentSnapshot()
                } else {
                    self.deliverNoContentSnapshot(hiddenCollectibleCount: hiddenCollectibleCount)
                }

                return nil
            }

            var snapshot = Snapshot()

            if self.isWatchAccount {
                self.addWatchAccountHeaderContent(
                    withCollectibleCount: collectibleItems.count,
                    to: &snapshot
                )
            } else {
                self.addHeaderContent(
                    withCollectibleCount: collectibleItems.count,
                    to: &snapshot
                )
            }

            snapshot.appendSections([.uiActions, .collectibles])

            snapshot.appendItems(
                [.uiActions],
                toSection: .uiActions
            )

            snapshot.appendItems(
                pendingCollectibleItems,
                toSection: .collectibles
            )

            snapshot.appendItems(
                collectibleItems,
                toSection: .collectibles
            )

            return snapshot
        }
    }

    private func deliverNoContentSnapshot(hiddenCollectibleCount: Int = .zero) {
        deliverSnapshot {
            [weak self] in
            guard let self else { return Snapshot() }

            var snapshot = Snapshot()
            let viewModel = CollectiblesNoContentWithActionViewModel(
                hiddenCollectibleCount: hiddenCollectibleCount,
                isWatchAccount: self.isWatchAccount
            )
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent(viewModel))],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverSearchNoContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self else { return Snapshot() }

            var snapshot = Snapshot()

            if self.isWatchAccount {
                self.addWatchAccountHeaderContent(
                    withCollectibleCount: .zero,
                    to: &snapshot
                )
            } else {
                self.addHeaderContent(
                    withCollectibleCount: .zero,
                    to: &snapshot
                )
            }

            snapshot.appendSections([.uiActions, .empty])

            snapshot.appendItems(
                [.uiActions],
                toSection: .uiActions
            )

            snapshot.appendItems(
                [.empty(.noContentSearch)],
                toSection: .empty
            )

            return snapshot
        }
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot?
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self else { return }

            guard let snapshot = snapshot() else { return }

            self.publish(.didUpdate(snapshot))
        }
    }
}

extension CollectibleListLocalDataController {
    private func addHeaderContent(
        withCollectibleCount count: Int,
        to snapshot: inout Snapshot
    ) {
        let viewModel = ManagementItemViewModel(
            .collectible(
                count: count,
                isWatchAccountDisplay: false
            )
         )
        snapshot.appendSections([.header])
        snapshot.appendItems(
            [.header(viewModel)],
            toSection: .header
        )
    }

    private func addWatchAccountHeaderContent(
        withCollectibleCount count: Int,
        to snapshot: inout Snapshot
    ) {
        let viewModel = ManagementItemViewModel(
            .collectible(
                count: count,
                isWatchAccountDisplay: true
            )
        )
        snapshot.appendSections([.header])
        snapshot.appendItems(
            [.watchAccountHeader(viewModel)],
            toSection: .header
        )
    }
}

extension CollectibleListLocalDataController {
    private func makePendingCollectibleListItems() -> [CollectibleListItem] {
        var pendingCollectibleItems: [CollectibleListItem] = []

        let monitor = sharedDataController.blockchainUpdatesMonitor

        let pendingOptInAssets = monitor.filterPendingOptInAssetUpdates()
        for pendingOptInAsset in pendingOptInAssets {
            let update = pendingOptInAsset

            if update.isCollectibleAsset {
                let item = makePendingCollectibleAssetOptInItem(update)
                pendingCollectibleItems.append(item)
                continue
            }
        }

        let pendingOptOutAssets = monitor.filterPendingOptOutAssetUpdates()
        for pendingOptOutAsset in pendingOptOutAssets {
            let update = pendingOptOutAsset

            if update.isCollectibleAsset {
                let item = makePendingCollectibleAssetOptOutItem(update)
                pendingCollectibleItems.append(item)
                continue
            }
        }

        return pendingCollectibleItems
    }

    private func makeCollectibleListItems(
        query: String?,
        hiddenCollectibleCount: inout Int
    ) ->  [CollectibleListItem]{
        var collectibleItems: [CollectibleListItem] = makePendingCollectibleListItems()

        let collectibleAssets = formSortedCollectibleAssets()
        collectibleAssets.forEach { collectibleAsset in
            guard
                let address = collectibleAsset.optedInAddress,
                let account = accounts.account(for: address)
            else {
                return
            }

            /// <note>
            /// Since we are showing separate pending item for pending opt out. We should filter collectible asset according to.
            let monitor = sharedDataController.blockchainUpdatesMonitor
            let hasPendingOptOut = monitor.hasPendingOptOutRequest(
                assetID: collectibleAsset.id,
                for: account
            )
            if hasPendingOptOut {
                return
            }

            guard shouldDisplayWatchAccountCollectibleAsset(account) else {
                hiddenCollectibleCount += 1
                return
            }

            guard shouldDisplayOptedInCollectibleAsset(collectibleAsset) else {
                hiddenCollectibleCount += 1
                return
            }

            if let query = query,
               !isAssetContains(collectibleAsset, query: query) {
                return
            }

            let item = makeCollectibleAssetItem(account: account, asset: collectibleAsset)
            collectibleItems.append(item)
        }

        return collectibleItems
    }

}

extension CollectibleListLocalDataController {
    private func makeCollectibleAssetItem(account: Account, asset: CollectibleAsset) -> CollectibleListItem {
        let galleryUIStyle = collectibleGalleryUIStyleStore.galleryUIStyle

        if galleryUIStyle == CollectibleGalleryUIActionsView.gridUIStyleIndex {
           return makeCollectibleAssetListItem(account: account, asset: asset)
        } else {
            return makeCollectibleAssetListItemNew(account: account, asset: asset)
        }
    }

    private func makePendingCollectibleAssetOptOutItem(_ update: OptOutBlockchainUpdate) -> CollectibleListItem {
        let galleryUIStyle = collectibleGalleryUIStyleStore.galleryUIStyle

        if galleryUIStyle == CollectibleGalleryUIActionsView.gridUIStyleIndex {
           return makePendingCollectibleAssetOptOutListItem(update)
        } else {
            return makePendingCollectibleAssetOptOutListItemNew(update)
        }
    }

    private func makePendingCollectibleAssetOptInItem(_ update: OptInBlockchainUpdate) -> CollectibleListItem {
        let galleryUIStyle = collectibleGalleryUIStyleStore.galleryUIStyle

        if galleryUIStyle == CollectibleGalleryUIActionsView.gridUIStyleIndex {
           return makePendingCollectibleAssetOptInListItem(update)
        } else {
            return makePendingCollectibleAssetOptInListItemNew(update)
        }
    }
}

extension CollectibleListLocalDataController {
    private func makeCollectibleAssetListItem(account: Account, asset: CollectibleAsset) -> CollectibleListItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let listItem = CollectibleListCollectibleAssetListItem(
            imageSize: imageSize,
            item: collectibleAssetItem
        )
        return .collectibleAsset(.grid(listItem))
    }

    private func makePendingCollectibleAssetOptInListItem(_ update: OptInBlockchainUpdate) -> CollectibleListItem {
        let listItem = CollectibleListPendingCollectibleAssetListItem(
            imageSize: imageSize,
            update: update
        )
        return .pendingCollectibleAsset(.grid(listItem))
    }

    private func makePendingCollectibleAssetOptOutListItem(_ update: OptOutBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetListItem(
            imageSize: imageSize,
            update: update
        )
        return .pendingCollectibleAsset(.grid(item))
    }
}

extension CollectibleListLocalDataController {
    private func makeCollectibleAssetListItemNew(account: Account, asset: CollectibleAsset) -> CollectibleListItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let listItem = CollectibleListCollectibleAssetListItemNew(item: collectibleAssetItem)
        return .collectibleAsset(.list(listItem))
    }

    private func makePendingCollectibleAssetOptInListItemNew(_ update: OptInBlockchainUpdate) -> CollectibleListItem {
        let listItem = CollectibleListPendingCollectibleAssetListItemNew(update: update)
        return .pendingCollectibleAsset(.list(listItem))
    }

    private func makePendingCollectibleAssetOptOutListItemNew(_ update: OptOutBlockchainUpdate) -> CollectibleListItem {
        let listItem = CollectibleListPendingCollectibleAssetListItemNew(update: update)
        return .pendingCollectibleAsset(.list(listItem))
    }
}

extension CollectibleListLocalDataController {
    private func shouldDisplayWatchAccountCollectibleAsset(_ account: Account) -> Bool {
        if !galleryAccount.isAll {
            return true
        }

        if !account.isWatchAccount() {
            return true
        }

        return collectibleFilterOptions.displayWatchAccountCollectibleAssetsInCollectibleList
    }

    private func shouldDisplayOptedInCollectibleAsset(_ collectibleAsset: CollectibleAsset) -> Bool {
        if collectibleAsset.isOwned {
            return true
        }

        return collectibleFilterOptions.displayOptedInCollectibleAssetsInCollectibleList
    }
}

extension CollectibleListLocalDataController {
    private func formSortedCollectibleAssets() -> [CollectibleAsset] {
        func formCollectibleAssets(
            _ collectibles: [CollectibleAsset],
            appendingCollectiblesOf account: AccountHandle
        ) -> [CollectibleAsset] {
            let newCollectibles = account.value.collectibleAssets.someArray
            return collectibles + newCollectibles
        }

        if let collectibleSortingAlgorithm = sharedDataController.selectedCollectibleSortingAlgorithm {
            let collectibleAssets = accounts.reduce([], formCollectibleAssets)
            return collectibleAssets.sorted(collectibleSortingAlgorithm)
        }

        let sortedAccounts: [AccountHandle]
        if let accountSortingAlgorithm = sharedDataController.selectedAccountSortingAlgorithm {
            sortedAccounts = accounts.sorted(accountSortingAlgorithm)
        } else {
            sortedAccounts = accounts.map { $0 }
        }

        return sortedAccounts.reduce([], formCollectibleAssets)
    }
}

extension CollectibleListLocalDataController {
    private func publish(
        _ event: CollectibleDataControllerEvent
    ) {
        asyncMain {
            [weak self] in
            guard let self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}

extension CollectibleListLocalDataController {
    private func isAssetContains(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return isAssetContainsTitle(asset, query: query) ||
        isAssetContainsID(asset, query: query) ||
        isAssetContainsName(asset, query: query) ||
        isAssetContainsUnitName(asset, query: query)
    }

    private func isAssetContainsTitle(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return asset.title.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsID(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return String(asset.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return asset.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return asset.unitName.someString.localizedCaseInsensitiveContains(query)
    }
}

struct CollectibleGalleryUIStyleStore: Storable {
    typealias Object = Any

    var galleryUIStyle: Int {
        get { userDefaults.integer(forKey: galleryUIStyleKey) }
        set { userDefaults.set(newValue, forKey: galleryUIStyleKey) }
    }

    private let galleryUIStyleKey = "cache.key.collectibleGalleryUIStyle"
}
