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

final class CollectibleListLocalDataController:
    CollectibleListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((CollectibleDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.collectibleListDataController")

    private var accounts: [AccountHandle]
    private let sharedDataController: SharedDataController

    private var collectibleAssets: [CollectibleAsset] {
        accounts
            .map { $0.value.collectibleAssets }
            .flatMap { $0 }.uniqueElements(for: \.id)
    }

    private lazy var searchResults: [CollectibleAsset] = collectibleAssets

    private let isWatchAccount: Bool

    init(
        isWatchAccount: Bool = false,
        accounts: [AccountHandle],
        sharedDataController: SharedDataController
    ) {
        self.isWatchAccount = isWatchAccount
        self.accounts = accounts
        self.sharedDataController = sharedDataController
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
        searchResults = collectibleAssets.filter { asset in
            isAssetContainsID(asset, query: query) ||
            isAssetContainsName(asset, query: query) ||
            isAssetContainsUnitName(asset, query: query)
        }

        deliverContentSnapshot()
    }

    func resetSearch() {
        searchResults = collectibleAssets
        deliverContentSnapshot()
    }

    private func isAssetContainsID(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return String(asset.id).contains(query)
    }

    private func isAssetContainsName(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return asset.name.someString.contains(query)
    }

    private func isAssetContainsUnitName(
        _ asset: CollectibleAsset,
        query: String
    ) -> Bool {
        return asset.unitName.someString.contains(query)
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
            /// <todo> Update accounts

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
        guard !collectibleAssets.isEmpty else {
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

                let isNotOwner = collectible.amount == 0 /// <note> Not owner of this asset but opted in for it.

                if isNotOwner {
                    cellItem = .cell(
                        .translucent(CollectibleListItemViewModel(collectible))
                    )
                } else {
                    cellItem = .cell(
                        .opaque(CollectibleListItemViewModel(collectible))
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
