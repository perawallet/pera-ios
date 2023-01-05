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

    var galleryUIStyle: CollectibleGalleryUIStyle = .grid

    private var lastSnapshot: Snapshot?
    private var lastQuery: String?

    private lazy var collectibleAmountFormatter: CollectibleAmountFormatter = .init()
    
    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.4)
    
    private lazy var collectibleFilterOptions: CollectibleFilterOptions = .init()

    private let updateQueue = DispatchQueue(
        label: "pera.queue.collectibles.updates",
        qos: .userInitiated
    )

    let galleryAccount: CollectibleGalleryAccount

    private var accounts: AccountCollection = []
    private let sharedDataController: SharedDataController

    private let isWatchAccount: Bool

    var imageSize: CGSize = .zero

    private var canPerformUpdates = true

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
        deliverContentUpdate(query: lastQuery)
    }

    func search(for query: String) {
        searchThrottler.performNext {
            [weak self] in
            guard let self = self else { return }

            self.deliverContentUpdate(query: query)
        }
    }

    func resetSearch() {
        searchThrottler.cancelAll()

        deliverContentUpdate()
    }
}

extension CollectibleListLocalDataController {
    func startUpdates() {
        canPerformUpdates = true
    }

    func stopUpdates() {
        canPerformUpdates = false
    }
}

extension CollectibleListLocalDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didBecomeIdle:
            deliverInitialUpdate()
        case .didStartRunning(let isFirst):
            if isFirst || lastSnapshot == nil {
                deliverInitialUpdate()
            }
        case .didFinishRunning:
            switch galleryAccount {
            case .single(let account):
                guard let updatedAccount = sharedDataController.accountCollection[account.value.address] else {
                    return
                }

                if lastSnapshot == nil {
                    deliverInitialUpdate()
                }

                if case .failed = updatedAccount.status {
                    eventHandler?(.didFinishRunning(hasError: true))
                    return
                }

                eventHandler?(.didFinishRunning(hasError: false))

                accounts = [updatedAccount]

                deliverContentUpdate(query: lastQuery)
            case .all:
                let accounts = sharedDataController.accountCollection

                if lastSnapshot == nil {
                    deliverInitialUpdate()
                }

                for account in accounts {
                    if case .failed = account.status {
                        eventHandler?(.didFinishRunning(hasError: true))
                        return
                    }
                }

                eventHandler?(.didFinishRunning(hasError: false))

                self.accounts = accounts

                deliverContentUpdate(query: lastQuery)
            }
        }
    }
}

extension CollectibleListLocalDataController {
    private func deliverInitialUpdate() {
        if sharedDataController.isPollingAvailable {
            deliverLoadingUpdate(query: lastQuery)
        } else {
            deliverNoContentUpdate(query: lastQuery)
        }
    }

    private func deliverLoadingUpdate(query: String?) {
        deliverUpdate {
            [weak self] in
            guard let self else { return nil }

            var snapshot = Snapshot()
            let item = self.makeLoadingItem()
            snapshot.appendSections([.loading])
            snapshot.appendItems(
                [item],
                toSection: .loading
            )
            let update = CollectibleListUpdate(
                query: query,
                snapshot: snapshot
            )
            return update
        }
    }

    private func deliverContentUpdate(query: String? = nil) {
        deliverUpdate {
            [weak self] in
            guard let self else { return nil }

            let pendingCollectibleItems = self.makePendingCollectibleListItems()
            let collectibleList = self.makeCollectibleList(query: query)

            let shouldShowEmptyContent = pendingCollectibleItems.isEmpty && collectibleList.isEmpty

            if shouldShowEmptyContent {
                let isSearching = !query.isNilOrEmpty

                if isSearching {
                    self.deliverSearchNoContentUpdate(query: query)
                } else {
                    self.deliverNoContentUpdate(
                        query: query,
                        collectibleList: collectibleList
                    )
                }

                return nil
            }

            var snapshot = Snapshot()

            let visibleCollectibleItems = collectibleList.visibleItems

            if self.isWatchAccount {
                self.addWatchAccountHeaderContent(
                    withCollectibleCount: visibleCollectibleItems.count,
                    to: &snapshot
                )
            } else {
                self.addHeaderContent(
                    withCollectibleCount: visibleCollectibleItems.count,
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
                visibleCollectibleItems,
                toSection: .collectibles
            )

            let update = CollectibleListUpdate(
                query: query,
                snapshot: snapshot
            )
            return update
        }
    }

    private func deliverNoContentUpdate(
        query: String?,
        collectibleList: CollectibleList? = nil
    ) {
        deliverUpdate {
            [weak self] in
            guard let self else { return nil }

            var snapshot = Snapshot()
            let viewModel = CollectiblesNoContentWithActionViewModel(
                hiddenCollectibleCount: collectibleList?.hiddenCount ?? .zero,
                isWatchAccount: self.isWatchAccount
            )
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent(viewModel))],
                toSection: .empty
            )
            let update = CollectibleListUpdate(
                query: query,
                snapshot: snapshot
            )
            return update
        }
    }

    private func deliverSearchNoContentUpdate(query: String?) {
        deliverUpdate {
            [weak self] in
            guard let self else { return nil }

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

            let update = CollectibleListUpdate(
                query: query,
                snapshot: snapshot
            )
            return update
        }
    }

    private func deliverUpdate(_ update: @escaping () -> CollectibleListUpdate?) {
        updateQueue.async {
            [weak self] in
            guard let self else { return }

            guard self.canPerformUpdates else { return  }

            guard let update = update() else { return }

            self.publish(.didUpdate(update))
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
    private func makeLoadingItem() -> CollectibleListItem {
        if galleryUIStyle.isGrid {
            return .empty(.loading(.grid))
        } else {
            return .empty(.loading(.list))
        }
    }
}

extension CollectibleListLocalDataController {
    private func makePendingCollectibleListItems() -> [CollectibleListItem] {
        let monitor = sharedDataController.blockchainUpdatesMonitor

        let pendingOptInAssets = monitor.filterPendingOptInAssetUpdates()
        let pendingOptInCollectibleItems = pendingOptInAssets.compactMap {
            return $0.isCollectibleAsset ? makePendingCollectibleAssetOptInItem($0) : nil
        }

        let pendingOptOutAssets = monitor.filterPendingOptOutAssetUpdates()
        let pendingOptOutCollectibleItems = pendingOptOutAssets.compactMap {
            return $0.isCollectibleAsset ? makePendingCollectibleAssetOptOutItem($0) : nil
        }

        
        let pendingSendPureCollectibleAssets = monitor.filterPendingSendPureCollectibleAssetUpdates()
        let pendingSendPureCollectibleItems =
            pendingSendPureCollectibleAssets.map(makePendingPureCollectibleAssetSendItem)

        return pendingOptInCollectibleItems + pendingOptOutCollectibleItems + pendingSendPureCollectibleItems
    }

    private func makeCollectibleList(query: String?) ->  CollectibleList {
        let collectibleAssets = formSortedCollectibleAssets()

        let collectibleItems: [CollectibleListItem] = collectibleAssets.compactMap { collectibleAsset in
            guard let account = account(for: collectibleAsset) else {
                return nil
            }

            /// <note>
            /// Since we are showing separate pending item for pending opt out, we should filter collectible asset according to.
            let hasPendingOptOut = hasPendingOptOut(
                collectibleAsset: collectibleAsset,
                account: account
            )
            if hasPendingOptOut {
                return nil
            }
            /// <note>
            /// Since we are showing separate pending item for pending send pur collectible asset, we should filter collectible asset according to.
            let hasPendingSendPureCollectibleAsset = hasPendingSendPureCollectibleAsset(
                collectibleAsset: collectibleAsset,
                account: account
            )
            if hasPendingSendPureCollectibleAsset {
                return nil
            }

            guard shouldDisplayWatchAccountCollectibleAsset(account) else {
                return nil
            }

            guard shouldDisplayOptedInCollectibleAsset(collectibleAsset) else {
                return nil
            }

            if let query = query,
               !isAssetContains(collectibleAsset, query: query) {
                return nil
            }

            let item = makeCollectibleAssetItem(account: account, asset: collectibleAsset)
            return item
        }

        let collectibleList = CollectibleList(
            allItems: collectibleAssets,
            visibleItems: collectibleItems
        )
        return collectibleList
    }
}

extension CollectibleListLocalDataController {
    private func makeCollectibleAssetItem(account: Account, asset: CollectibleAsset) -> CollectibleListItem {
        if galleryUIStyle.isGrid {
            return makeCollectibleAssetGridItem(account: account, asset: asset)
        } else {
            return makeCollectibleAssetListItem(account: account, asset: asset)
        }
    }

    private func makePendingCollectibleAssetOptOutItem(_ update: OptOutBlockchainUpdate) -> CollectibleListItem {
        if galleryUIStyle.isGrid {
            return makePendingCollectibleAssetOptOutGridItem(update)
        } else {
            return makePendingCollectibleAssetOptOutListItem(update)
        }
    }

    private func makePendingCollectibleAssetOptInItem(_ update: OptInBlockchainUpdate) -> CollectibleListItem {
        if galleryUIStyle.isGrid {
            return makePendingCollectibleAssetOptInGridItem(update)
        } else {
            return makePendingCollectibleAssetOptInListItem(update)
        }
    }

    private func makePendingPureCollectibleAssetSendItem(_ update: SendPureCollectibleAssetBlockchainUpdate) -> CollectibleListItem {
        if galleryUIStyle.isGrid {
            return makePendingPureCollectibleAssetSendGridItem(update)
        } else {
            return makePendingPureCollectibleAssetSendListItem(update)
        }
    }
}

extension CollectibleListLocalDataController {
    private func makeCollectibleAssetGridItem(account: Account, asset: CollectibleAsset) -> CollectibleListItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let gridItem = CollectibleListCollectibleAssetGridItem(
            imageSize: imageSize,
            item: collectibleAssetItem
        )
        return .collectibleAsset(.grid(gridItem))
    }

    private func makePendingCollectibleAssetOptInGridItem(_ update: OptInBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetGridItem(
            imageSize: imageSize,
            update: update
        )
        return .pendingCollectibleAsset(.grid(item))
    }

    private func makePendingCollectibleAssetOptOutGridItem(_ update: OptOutBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetGridItem(
            imageSize: imageSize,
            update: update
        )
        return .pendingCollectibleAsset(.grid(item))
    }

    private func makePendingPureCollectibleAssetSendGridItem(_ update: SendPureCollectibleAssetBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetGridItem(
            imageSize: imageSize,
            update: update
        )
        return .pendingCollectibleAsset(.grid(item))
    }
}

extension CollectibleListLocalDataController {
    private func makeCollectibleAssetListItem(account: Account, asset: CollectibleAsset) -> CollectibleListItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: collectibleAmountFormatter
        )
        let listItem = CollectibleListCollectibleAssetListItem(item: collectibleAssetItem)
        return .collectibleAsset(.list(listItem))
    }

    private func makePendingCollectibleAssetOptInListItem(_ update: OptInBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(.list(item))
    }

    private func makePendingCollectibleAssetOptOutListItem(_ update: OptOutBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(.list(item))
    }

    private func makePendingPureCollectibleAssetSendListItem(_ update: SendPureCollectibleAssetBlockchainUpdate) -> CollectibleListItem {
        let item = CollectibleListPendingCollectibleAssetListItem(update: update)
        return .pendingCollectibleAsset(.list(item))
    }
}

extension CollectibleListLocalDataController {
    private func account(for collectibleAsset: CollectibleAsset) -> Account? {
        let address = collectibleAsset.optedInAddress
        let account = address.unwrap { accounts.account(for: $0) }
        return account
    }
}

extension CollectibleListLocalDataController {
    private func hasPendingOptOut(
        collectibleAsset: CollectibleAsset,
        account: Account
    ) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        return monitor.hasPendingOptOutRequest(
            assetID: collectibleAsset.id,
            for: account
        )
    }

    private func hasPendingSendPureCollectibleAsset(
        collectibleAsset: CollectibleAsset,
        account: Account
    ) -> Bool {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        return monitor.hasPendingSendPureCollectibleAssetRequest(
            assetID: collectibleAsset.id,
            for: account
        )
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
            self.lastQuery = event.query
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

private extension CollectibleListLocalDataController {
    struct CollectibleList {
        var totalCount: Int {
            return allItems.count
        }
        var visibleCount: Int {
            return visibleItems.count
        }
        var hiddenCount: Int {
            return totalCount - visibleItems.count
        }

        var isEmpty: Bool {
            return visibleItems.isEmpty
        }

        let allItems: [CollectibleAsset]
        let visibleItems: [CollectibleListItem]
    }
}

extension CollectibleListLocalDataController {
    typealias Snapshot = CollectibleListUpdate.Snapshot
}
