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
import MagpieHipo

final class AssetListViewAPIDataController:
    AssetListViewDataController,
    SharedDataControllerObserver {
    var eventHandler: ((AssetListViewDataControllerEvent) -> Void)?
    
    private lazy var apiThrottler = Throttler(intervalInSeconds: 0.4)

    private(set) var account: Account
        
    private var draft: AssetSearchQuery?
    private var snapshot: Snapshot?
    private var ongoingEndpoint: EndpointOperatable?
    
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let updatesQueue = DispatchQueue(
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
        apply(keyword: keyword)
        deliverUpdatesForLoading()
        
        if let draft = draft {
            fetchData(with: draft)
        } else {
            fetchInitialData()
        }
    }
    
    func apply(keyword: String?) {
        draft?.query = keyword
        draft?.cursor = nil
    }
    
    private func fetchData(with draft: AssetSearchQuery) {
        apiThrottler.performNext {
            [weak self] in
            guard let self else { return }
            
            self.getAssets(draft: draft) {
                [weak self] response in
                guard let self else { return }
                
                switch response {
                case .success(let changes):
                    self.deliverUpdatesForAssets(changes)
                case .failure(let error):
                    self.deliverUpdatesForError(error)
                }
            }
        }
    }
    
    private func fetchInitialData() {
        apiThrottler.cancelAll()
        
        draft = AssetSearchQuery()
        sharedDataController.add(self)
        loadData(keyword: nil)
    }
    
    func loadNextData() {
        if hasDataBeingLoaded() { return }
        if !hasNextDataToBeLoaded() { return }
        
        guard let draft else { return }

        if let snapshot = snapshot,
           snapshot.sectionIdentifiers.last == .nextList,
           snapshot.itemIdentifiers(inSection: .nextList).first != .nextListLoading {
            deliverUpdatesForNextLoading()
        }
        
        self.getAssets(draft: draft) {
            [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let changes):
                self.deliverUpdatesForNextAssets(changes)
            case .failure(let error):
                self.deliverUpdatesForNextError(error)
            }
        }
    }
    
    func hasDataBeingLoaded() -> Bool {
        return !ongoingEndpoint.isNilOrFinished
    }
    
    func hasNextDataToBeLoaded() -> Bool {
        return draft?.cursor != nil
    }
}

extension AssetListViewAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
            
            updatesQueue.async {
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
    private func deliverUpdatesForLoading() {
        if let snapshot = snapshot,
           snapshot.sectionIdentifiers.first == .assetList,
           snapshot.itemIdentifiers(inSection: .assetList).last == .loading {
            return
        }
        
        deliverUpdates {
            [weak self] in
            guard let self else { return nil }
            
            return self.makeUpdatesForLoading()
        }
    }
    
    private func makeUpdatesForLoading() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.assetList])
        snapshot.appendItems(
            [.loading],
            toSection: .assetList
        )
        
        return snapshot
    }
    
    private func deliverUpdatesForAssets(_ changes: GetAssetsChanges) {
        deliverUpdates {
            [weak self] in
            guard let self else { return nil }
            
            let snapshot: Snapshot

            if changes.assets.isEmpty {
                snapshot = self.makeUpdatesForNoContent()
            } else {
                snapshot = self.makeUpdatesForAssets(changes)
            }
            
            return snapshot
        }
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
    
    private func makeUpdatesForAssets(_ changes: GetAssetsChanges) -> Snapshot {
        var snapshot = Snapshot()
        let assetItems: [AssetListViewItem] = changes.assets.map {
            let item = OptInAssetListItem(asset: $0)
            return AssetListViewItem.asset(item)
        }
        snapshot.appendSections([.assetList])
        snapshot.appendItems(
            assetItems,
            toSection: .assetList
        )
        
        if changes.hasNextAssets {
            snapshot.appendSections([.nextList])
            snapshot.appendItems(
                [.nextListLoading],
                toSection: .nextList
            )
        }
        
        return snapshot
    }
    
    private func deliverUpdatesForError(_ error: GetAssetsError) {
        deliverUpdates {
            [weak self] in
            guard let self else { return nil }

            return self.makeUpdatesForError(error: error)
        }
    }

    private func makeUpdatesForError(error: GetAssetsError) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.error(createErrorItem(error: error))],
            toSection: .empty
        )
        return snapshot
    }

    private func createErrorItem(error: HIPNetworkError<NoAPIModel>) -> AssetListErrorItem {
        let fallbackTitle = "title-generic-api-error".localized
        let fallbackBody = "\("asset-search-not-found".localized)\n\("title-retry-later".localized)"

        let title: String
        let body: String
        switch error {
        case .connection(let connectionError):
            if connectionError.isNotConnectedToInternet {
                title = "discover-error-connection-title".localized
                body = "discover-error-connection-body".localized
            } else {
                title = fallbackTitle
                body = fallbackBody
            }
        default:
            title = fallbackTitle
            body = fallbackBody
        }
        
        return AssetListErrorItem(title: title, body: body)
    }
    
    private func deliverUpdatesForNextLoading() {
        deliverUpdates {
            [weak self] in
            guard let self else { return nil }
            guard var snapshot = self.snapshot else { return Snapshot() }
            
            snapshot.deleteSections([.nextList])
            snapshot.appendSections([.nextList])
            snapshot.appendItems(
                [.nextListLoading],
                toSection: .nextList
            )
            
            return snapshot
        }
    }
    
    private func deliverUpdatesForNextAssets(_ changes: GetAssetsChanges) {
        deliverUpdates {
            [weak self] in
            guard let self else { return nil }

            return self.makeUpdatesForNextAssets(changes)
        }
    }
    
    private func makeUpdatesForNextAssets(_ changes: GetAssetsChanges) -> Snapshot {
        guard var snapshot = self.snapshot else { return Snapshot() }
        
        let assetItems: [AssetListViewItem] = changes.assets.map {
            let item = OptInAssetListItem(asset: $0)
            return AssetListViewItem.asset(item)
        }
        
        snapshot.appendItems(
            assetItems,
            toSection: .assetList
        )
        
        if !changes.hasNextAssets {
            snapshot.deleteSections([.nextList])
        }
        
        return snapshot
    }
    
    private func deliverUpdatesForNextError(_ error: GetAssetsError) {
        deliverUpdates {
            [weak self] in
            guard let self else { return nil }

            return self.makeUpdatesForNextError(error: error)
        }
    }
    
    private func makeUpdatesForNextError(error: GetAssetsError) -> Snapshot {
        guard var snapshot = self.snapshot else { return Snapshot() }
        
        snapshot.deleteSections([.nextList])
        snapshot.appendSections([.nextList])
        snapshot.appendItems(
            [.nextListError(createErrorItem(error: error))],
            toSection: .nextList
        )
        return snapshot
    }
}

extension AssetListViewAPIDataController {
    private func deliverUpdates(
        _ snapshot: @escaping () -> Snapshot?
    ) {
        updatesQueue.async {
            [weak self] in
            guard let self else { return }
            guard let newSnapshot = snapshot() else { return }
            
            self.snapshot = newSnapshot
            
            self.publish(event: .didUpdateAssets(newSnapshot))
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
    private typealias GetAssetsChanges = (assets: [AssetDecoration], hasNextAssets: Bool)
    private typealias GetAssetsError = HIPNetworkError<NoAPIModel>
    private typealias GetAssetsCompletion = (Result<GetAssetsChanges, GetAssetsError>) -> Void

    private func getAssets(
        draft: AssetSearchQuery,
        completion: @escaping GetAssetsCompletion
    ) {
        ongoingEndpoint = api.searchAssets(
            draft,
            ignoreResponseOnCancelled: false
        ) {
            [weak self] response in
            guard let self else { return }
            
            self.ongoingEndpoint = nil
            
            switch response {
            case .success(let list):
                self.draft?.cursor = list.nextCursor
                let changes = (list.results, !list.nextCursor.isNilOrEmpty)
                completion(.success(changes))
            case .failure(let apiError, let apiErrorDetail):
                let error = GetAssetsError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                completion(.failure(error))
            }
        }
    }
}
