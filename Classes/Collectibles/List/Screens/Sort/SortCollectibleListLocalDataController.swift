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

//   SortCollectibleListLocalDataController.swift

import Foundation

final class SortCollectibleListLocalDataController: SortCollectibleListDataController {
    var eventHandler: ((SortCollectibleListDataControllerEvent) -> Void)?

    private(set) var selectedSortingAlgorithm: CollectibleSortingAlgorithm {
        didSet {
            if selectedSortingAlgorithm.id != oldValue.id {
                deliverContentSnapshot()
            }
        }
    }

    private let sortingAlgorithms: [CollectibleSortingAlgorithm]

    private let session: Session
    private let sharedDataController: SharedDataController

    private let snapshotQueue = DispatchQueue(label: "sortCollectibleListSnapshot")

    init(
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.session = session
        self.sharedDataController = sharedDataController
        self.sortingAlgorithms = sharedDataController.collectibleSortingAlgorithms
        self.selectedSortingAlgorithm =
            sharedDataController.selectedCollectibleSortingAlgorithm ?? CollectibleDescendingOptedInRoundAlgorithm()
    }
}

extension SortCollectibleListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension SortCollectibleListLocalDataController {
    func selectItem(
        at indexPath: IndexPath
    ) {
        guard let newSelectedSortingAlgorithm = sortingAlgorithms[safe: indexPath.item] else {
            return
        }

        selectedSortingAlgorithm = newSelectedSortingAlgorithm
    }
}

extension SortCollectibleListLocalDataController {
    func performChanges() {
        saveSelectedSortingAlgorithm()

        publish(.didComplete)
    }

    private func saveSelectedSortingAlgorithm() {
        sharedDataController.selectedCollectibleSortingAlgorithm = selectedSortingAlgorithm
    }
}

extension SortCollectibleListLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            self.addSortContent(&snapshot)

            return snapshot
        }
    }

    private func addSortContent(
        _ snapshot: inout Snapshot
    ) {
        /// <todo>
        /// View model and selection should be separated.
        let items: [SortCollectibleListItem] = sortingAlgorithms.map {
            let isSelected = $0.id == selectedSortingAlgorithm.id
            let viewModel = SingleSelectionViewModel(
                title: $0.name,
                isSelected: isSelected
            )
            let value = SelectionValue(
                value: viewModel,
                isSelected: isSelected
            )
            return .sortOption(value)
        }

        snapshot.appendSections([.sortOptions])
        snapshot.appendItems(
            items,
            toSection: .sortOptions
        )
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else {
                return
            }

            self.publish(.didUpdate(snapshot()))
        }
    }
}

extension SortCollectibleListLocalDataController {
    private func publish(
        _ event: SortCollectibleListDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}
