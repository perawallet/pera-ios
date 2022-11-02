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

//   DiscoveryASASearchAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class DiscoveryASASearchAPIDataController:
    DiscoveryASASearchDataController {
    var eventHandler: ((DiscoveryASASearchDataControllerEvent) -> Void)?

    private var assets: [DiscoveryASA] = []

    private var lastSnapshot: Snapshot?

    private lazy var searchThrottler = Throttler(intervalInSeconds: 0.3)

    private var draft = AssetSearchQuery()

    private var ongoingEndpoint: EndpointOperatable?
    private var ongoingEndpointToLoadNextPage: EndpointOperatable?

    private var hasNextPage: Bool {
        return draft.cursor != nil
    }

    private let api: ALGAPI

    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.discoveryASASearchDataController")

    init(
        api: ALGAPI
    ) {
        self.api = api
    }
}

extension DiscoveryASASearchAPIDataController {
    func load() {
        deliverLoadingSnapshot()
        loadData()
    }

    func search(for query: String?) {
        searchThrottler.performNext {
            [weak self] in
            guard let self = self else { return }

            self.draft.query = query
            self.draft.cursor = nil

            self.loadData()
        }
    }

    func loadNextPageIfNeeded(for indexPath: IndexPath) {
        if ongoingEndpointToLoadNextPage != nil { return }

        if !hasNextPage { return }

        if indexPath.item < assets.count - 3 { return }

        ongoingEndpointToLoadNextPage = api.searchDiscoverAssets(
            draft,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else { return }

            self.ongoingEndpointToLoadNextPage = nil

            switch response {
            case let .success(searchResults):
                let results = self.assets + searchResults.results
                self.assets = results
                self.draft.cursor = searchResults.nextCursor

                self.deliverContentSnapshot(next: true)
            case .failure:
                /// <todo>
                /// Handle error properly.
                break
            }
        }
    }

    private func loadData() {
        cancelOngoingEndpoint()

        ongoingEndpoint = api.searchDiscoverAssets(
            draft,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else { return }

            self.ongoingEndpoint = nil

            switch response {
            case let .success(searchResults):
                self.assets = searchResults.results
                self.draft.cursor = searchResults.nextCursor

                self.deliverContentSnapshot(next: false)
            case .failure:
                /// <todo>
                /// Handle error properly.
                break
            }
        }
    }

    private func cancelOngoingEndpoint() {
        ongoingEndpointToLoadNextPage?.cancel()
        ongoingEndpointToLoadNextPage = nil

        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}

extension DiscoveryASASearchAPIDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot(next: false) {
            var snapshot = Snapshot()
            snapshot.appendSections([.assets])
            snapshot.appendItems([.loading("1"), .loading("2")], toSection: .assets)
            return snapshot
        }
    }

    private func deliverContentSnapshot(next: Bool) {
        guard !self.assets.isEmpty else {
            deliverNoContentSnapshot()
            return
        }

        deliverSnapshot(next: next) {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            snapshot.appendSections([ .assets ])

            let assetItems: [DiscoveryASASearchListItem] = self.assets.map {
                let item = DiscoveryASAItem(asset: $0)
                return DiscoveryASASearchListItem.asset(item)
            }
            snapshot.appendItems(
                assetItems,
                toSection: .assets
            )

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot(next: false) {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.noContent],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverSnapshot(
        next: Bool,
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }

            let newSnapshot = snapshot()

            self.lastSnapshot = newSnapshot

            let event: DiscoveryASASearchDataControllerEvent
            if next {
                event = .didUpdateNext(newSnapshot)
            } else {
                event = .didUpdate(newSnapshot)
            }

            self.publish(event)
        }
    }
}

extension DiscoveryASASearchAPIDataController {
    private func publish(
        _ event: DiscoveryASASearchDataControllerEvent
    ) {
        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            self.eventHandler?(event)
        }
    }
}
