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

final class CollectibleListLocalDataController:
    CollectibleListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((CollectibleDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.collectibleListDataController")

    private let galleryAccount: CollectibleGalleryAccount

    private var accounts: [AccountHandle]
    private let sharedDataController: SharedDataController

    private var collectibleAssets: [CollectibleAsset]

    private lazy var searchResults: [CollectibleAsset] = collectibleAssets

    private let isWatchAccount: Bool

    var imageSize: CGSize = .zero

    private var lastQuery: String?

    init(
        galleryAccount: CollectibleGalleryAccount,
        sharedDataController: SharedDataController
    ) {
        self.galleryAccount = galleryAccount

        switch galleryAccount {
        case .single(let account):
            accounts = [account]
            collectibleAssets = account.value.collectibleAssets.compactMap { $0 }.uniqueElements(for: \.id)
        case .all:
            accounts = sharedDataController.accountCollection.sorted()
            collectibleAssets = accounts
                .map { $0.value.collectibleAssets }
                .flatMap { $0 }.uniqueElements(for: \.id)
        }

        self.sharedDataController = sharedDataController
        self.isWatchAccount = galleryAccount.singleAccount?.value.isWatchAccount() ?? false
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension CollectibleListLocalDataController {
    func load() {
        sharedDataController.add(self)
    }

    func search(for query: String) {
        lastQuery = query

        searchResults = collectibleAssets.filter { asset in
            isAssetContainsTitle(asset, query: query) ||
            isAssetContainsID(asset, query: query) ||
            isAssetContainsName(asset, query: query) ||
            isAssetContainsUnitName(asset, query: query)
        }

        deliverContentSnapshot()
    }

    func resetSearch() {
        lastQuery = nil
        searchResults = collectibleAssets
        deliverContentSnapshot()
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
                if let updatedAccount = sharedDataController.accountCollection[account.value.address] {
                    accounts = [updatedAccount]
                    collectibleAssets = updatedAccount.value.collectibleAssets.compactMap { $0 }.uniqueElements(for: \.id)
                    searchResults = collectibleAssets

                    if let lastQuery = lastQuery {
                        search(for: lastQuery)
                    }
                }
            case .all:
                accounts = sharedDataController.accountCollection.sorted()
                collectibleAssets = accounts
                    .map { $0.value.collectibleAssets }
                    .flatMap { $0 }.uniqueElements(for: \.id)
                searchResults = collectibleAssets

                if let lastQuery = lastQuery {
                    search(for: lastQuery)
                }
            }

            deliverContentSnapshot()
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

    private func deliverContentSnapshot() {
        if collectibleAssets.isEmpty {
            deliverNoContentSnapshot()
            return
        }

        let searchResults = searchResults

        if searchResults.isEmpty {
            deliverSearchNoContentSnapshot()
            return
        }

        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()

            var collectibleItems: [CollectibleListItem] = []

            for collectible in searchResults {
                let cellItem: CollectibleItem

                if collectible.isOwned {
                    cellItem = .cell(
                        .owner(
                            CollectibleListItemViewModel(
                                imageSize: self.imageSize,
                                model: collectible
                            )
                        )
                    )
                } else {
                    cellItem = .cell(
                        .optedIn(
                            CollectibleListItemViewModel(
                                imageSize: self.imageSize,
                                model: collectible
                            )
                        )
                    )
                }

                let listItem: CollectibleListItem = .collectible(cellItem)
                collectibleItems.append(listItem)
            }

            snapshot.appendSections([.search, .collectibles])

            snapshot.appendItems(
                [.search],
                toSection: .search
            )
            
            snapshot.appendItems(
                collectibleItems,
                toSection: .collectibles
            )

            /// <todo> I think this shouldn't be handled like this for AccountCollectibleListViewController
            if !self.isWatchAccount {
                snapshot.appendItems(
                    [.collectible(.footer)],
                    toSection: .collectibles
                )
            }

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent)],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverSearchNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.search, .empty])

            snapshot.appendItems(
                [.search],
                toSection: .search
            )

            snapshot.appendItems(
                [.empty(.noContentSearch)],
                toSection: .empty
            )

            return snapshot
        }
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }
            self.publish(.didUpdate(snapshot()))
        }
    }
}

extension CollectibleListLocalDataController {
    private func publish(
        _ event: CollectibleDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}

extension CollectibleListLocalDataController {
    enum CollectibleGalleryAccount {
        case single(AccountHandle)
        case all

        var singleAccount: AccountHandle? {
            switch self {
            case .single(let account): return account
            default: return nil
            }
        }
    }
}
