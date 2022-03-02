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

//   CollectibleListAPIDataController.swift

import Foundation

final class CollectibleListAPIDataController:
    CollectibleListDataController,
    SharedDataControllerObserver {
    var eventHandler: ((CollectibleDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.collectibleListDataController")

    private let accounts: [AccountHandle]
    private let sharedDataController: SharedDataController

    init(
        accounts: [AccountHandle],
        sharedDataController: SharedDataController
    ) {
        self.accounts = accounts
        self.sharedDataController = sharedDataController
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension CollectibleListAPIDataController {
    func load() {
        sharedDataController.add(self)
    }

    func reload() {

    }
}

extension CollectibleListAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {

    }
}

extension CollectibleListAPIDataController {
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
        let collectibles = accounts.map { $0.value.collectibleAssets }.flatMap { $0 }.uniqueElements(for: \.id)
        if collectibles.isEmpty {
            deliverNoContentSnapshot()
            return
        }

        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()

            var collectibleItems: [CollectibleListItem] = []

            for collectible in collectibles {
                let cellItem: CollectibleItem = .cell(CollectibleListItemViewModel(collectible))
                let item: CollectibleListItem = .collectible(cellItem)
                collectibleItems.append(item)
            }

            snapshot.appendSections([.collectibles])
            snapshot.appendItems(
                collectibleItems,
                toSection: .collectibles
            )

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

extension CollectibleListAPIDataController {
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
