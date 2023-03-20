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
//   AssetListViewAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class AssetListViewAPIDataController:
    AssetListViewDataController,
    SharedDataControllerObserver {
    var eventHandler: ((AssetListViewDataControllerEvent) -> Void)?

    private(set) var account: Account

    private var assets: [AssetDecoration] = []
    
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    
    private lazy var apiThrottler = createAPIThrottler()
    
    private var lastSnapshot: Snapshot?
        
    private var query: AssetAdditionQuery?

    private var ongoingEndpoint: EndpointOperatable?
    
    private var snapshotQueue = DispatchQueue(
        label: "pera.queue.assetAddition.updates",
        qos: .userInitiated
    )

    init(
        account: Account,
        api: ALGAPI,
        sharedDataController: SharedDataController
    ) {
        self.account = account
        self.api = api
        self.sharedDataController = sharedDataController
    }

    deinit {
        sharedDataController.remove(self)
        apiThrottler.cancelAll()
        ongoingEndpoint?.cancel()
    }
}

extension AssetListViewAPIDataController {
    func loadData(keyword: String?) {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
        
        deliverUpdatesForLoading()
        
        let draft = apply(keyword: keyword)
        
        if let draft = draft {
            fetchData(with: draft)
        } else {
            fetchInitialData()
        }
    }
    
    func apply(keyword: String?) -> AssetSearchQuery? {
        query?.keyword = keyword
        query?.cursor = nil
        return query?.draft
    }
    
    private func fetchData(with draft: AssetSearchQuery) {
        apiThrottler.performNext {
            [weak self] in
            guard let self else { return }
            
            self.ongoingEndpoint = self.api.searchAssets(
                draft,
                ignoreResponseOnCancelled: false
            ) {
                [weak self] response in
                guard let self else { return }
                
                self.ongoingEndpoint = nil
                
                switch response {
                case .success(let list):
                    self.query?.cursor = list.nextCursor
                    self.assets = list.results
                    self.deliverUpdatesForAssets()
                case .failure:
                    break
                }
            }
        }
    }
    
    private func fetchInitialData() {
        apiThrottler.cancelAll()
        
        query = AssetAdditionQuery()
        sharedDataController.add(self)
        loadData(keyword: nil)
    }
    
    func loadNextData(for indexPath: IndexPath) {
        if !ongoingEndpoint.isNilOrFinished { return }
        
        if query?.cursor == nil { return }
        
        if indexPath.item < assets.count - 3 { return }
        
        guard let draft = query?.draft else { return }
        
        ongoingEndpoint = api.searchAssets(
            draft,
            ignoreResponseOnCancelled: false
        ) {
            [weak self] response in
            guard let self else { return }
            
            self.ongoingEndpoint = nil
            
            switch response {
            case .success(let nextList):
                self.query?.cursor = nextList.nextCursor
                self.assets += nextList.results
                self.deliverUpdatesForAssets(isNext: true)
            case .failure:
                break
            }
        }
    }
}


extension AssetListViewAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
            
            snapshotQueue.async {
                self.publish(event: .didUpdateAccount)
            }
        }
    }

    private func updateAccountIfNeeded() {
        let updatedAccount = sharedDataController.accountCollection[account.address]

        guard let account = updatedAccount else { return }

        if !account.isAvailable { return }

        self.account = account.value
    }
}

extension AssetListViewAPIDataController {
    private func deliverUpdatesForAssets(isNext: Bool = false) {
        deliverUpdates(isNext: isNext) {
            let snapshot: Snapshot

            if self.assets.isEmpty {
                snapshot = self.makeUpdatesForNoContent()
            } else {
                snapshot = self.makeUpdatesForContent()
            }
            
            return snapshot
        }
    }
    
    private func makeUpdatesForContent() -> Snapshot {
        var snapshot = Snapshot()
        let assetItems: [AssetListViewItem] = self.assets.map {
            let item = OptInAssetListItem(asset: $0)
            return AssetListViewItem.asset(item)
        }
        snapshot.appendSections([.assets])
        snapshot.appendItems(
            assetItems,
            toSection: .assets
        )
        
        return snapshot
    }
    
    private func deliverUpdatesForLoading() {
        if lastSnapshot?.sectionIdentifiers.first == .assets,
           lastSnapshot?.itemIdentifiers(inSection: .assets).last == .loading {
            return
        }
        
        deliverUpdates {
            return self.makeUpdatesForLoading()
        }
    }
    
    private func makeUpdatesForLoading() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.assets])
        snapshot.appendItems(
            [.loading],
            toSection: .assets
        )
        
        return snapshot
    }
    
    private func makeUpdatesForNoContent() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.noContent],
            toSection: .empty
        )
        
        return snapshot
    }
}

extension AssetListViewAPIDataController {
    private func deliverUpdates(
        isNext: Bool = false,
        _ snapshot: @escaping () -> Snapshot?
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self else { return }
            guard let newSnapshot = snapshot() else { return }
            
            self.lastSnapshot = newSnapshot
            
            if isNext {
                self.publish(event: .didLoadNext(newSnapshot))
            } else {
                self.publish(event: .didLoad(newSnapshot))
            }
        }
    }
    
    private func publish(event: AssetListViewDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self else { return }

            self.eventHandler?(event)
        }
    }
}

extension AssetListViewAPIDataController {
    func hasOptedIn(_ asset: AssetDecoration) -> OptInStatus {
        let monitor = sharedDataController.blockchainUpdatesMonitor
        let hasPendingOptedIn = monitor.hasPendingOptInRequest(
            assetID: asset.id,
            for: account
        )
        let hasAlreadyOptedIn = account[asset.id] != nil

        switch (hasPendingOptedIn, hasAlreadyOptedIn) {
        case (true, false): return .pending
        case (true, true): return .optedIn
        case (false, true): return .optedIn
        case (false, false): return .rejected
        }
    }
}

extension AssetListViewAPIDataController {
    private func createAPIThrottler() -> Throttler {
        return .init(intervalInSeconds: 0.4)
    }
}
