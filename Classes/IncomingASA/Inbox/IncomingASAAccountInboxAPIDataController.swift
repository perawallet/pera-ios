// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASAAccountInboxAPIDataController.swift

import Foundation
import MacaroonUtils

final class IncomingASAAccountInboxAPIDataController:
    IncomingASAAccountInboxDataController {
    var eventHandler: ((IncomingASAListDataControllerEvent) -> Void)?
    
    private(set)var requestsCount: Int
    private(set)var address: String
    
    private lazy var asyncLoadingQueue = createAsyncLoadingQueue()

    private lazy var currencyFormatter = createCurrencyFormatter()
    private lazy var assetAmountFormatter = createAssetAmountFormatter()
    
    private var query: IncomingASAsRequestDetailQuery = .init()
    private var lastSnapshot: Snapshot?
    private let sharedDataController: SharedDataController
    private let api: ALGAPI

    private var incomingASAsRequestDetail: IncomingASAsRequestDetailList?

    private var hasNextPage: Bool {
        return query.cursor != nil
    }
    
    init(
        address: String,
        requestsCount: Int,
        sharedDataController: SharedDataController,
        api: ALGAPI
    ) {
        self.address = address
        self.requestsCount = requestsCount
        self.sharedDataController = sharedDataController
        self.api = api
    }
}

extension IncomingASAAccountInboxAPIDataController {
    func load() {
        deliverUpdatesForLoading(for: .refresh)
        loadinitialData()
    }

    private func loadinitialData() {
        fetchIncomingASAsRequest(isInitialLoad: true)
    }
    
    private func loadNext() {
        if !hasNextPage { return }
        fetchIncomingASAsRequest(isInitialLoad: false)
    }
    
    private func fetchIncomingASAsRequest(isInitialLoad: Bool) {
        api.fetchIncomingASAsRequest(address, with: query) { [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let requestList):
                if isInitialLoad {
                    self.incomingASAsRequestDetail = requestList
                } else {
                    self.incomingASAsRequestDetail?.results.append(contentsOf: requestList.results)
                }
                if let nextCursor = requestList.nextCursor {
                    self.query.cursor = nextCursor
                    self.loadNext()
                } else {
                    self.query.cursor = nil
                }
                self.reload()
            case .failure(let apiError, _):
                self.publish(event: .didReceiveError(apiError.localizedDescription))
            }
        }
    }
    
    func reload() {
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            self.deliverUpdatesForContent(
                when: { self.query.cursor == nil },
                query: self.query,
                for: .refresh
            )
        }
        asyncLoadingQueue.add(task)
    }
}


extension IncomingASAAccountInboxAPIDataController {
    
    private func deliverUpdatesForLoading(for operation: Updates.Operation) {
        if lastSnapshot?.itemIdentifiers(inSection: .assets).last == .assetLoading {
            return
        }

        let updates = makeUpdatesForLoading(for: operation)
        publish(updates: updates)
    }
    
    private func makeUpdatesForLoading(for operation: Updates.Operation) -> Updates {
        var snapshot = Snapshot()
        appendSectionsForAssetsLoading(into: &snapshot)
        return Updates(snapshot: snapshot, operation: operation)
    }

    private func deliverUpdatesForContent(
        when condition: () -> Bool,
        query: IncomingASAsRequestDetailQuery?,
        for operation: Updates.Operation
    ) {
        let updates = makeUpdatesForContent(
            query: query,
            for: operation
        )

        if !condition() { return }
        if let query {
            self.query = query
        }
        self.publish(updates: updates)
    }

    private func makeUpdatesForContent(
        query: IncomingASAsRequestDetailQuery?,
        for operation: Updates.Operation
    ) -> Updates {
        
        if requestsCount == 0 {
            return makeUpdatesForNoContent(for: operation)
        }
        
        var snapshot = Snapshot()
        appendSectionsForAssets(
            query: query,
            into: &snapshot
        )
        return Updates(snapshot: snapshot, operation: operation)
    }
}

extension IncomingASAAccountInboxAPIDataController {

    private func appendSectionsForAssetsLoading(into snapshot: inout Snapshot) {
        let items = makeItemsForAssetsLoading()
        snapshot.appendSections([ .assets ])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
    }
    
    private func appendSectionsForAssets(
        query: IncomingASAsRequestDetailQuery?,
        into snapshot: inout Snapshot
    ) {
        let assetItems = makeItemsForAssets(assets: incomingASAsRequestDetail?.results ?? [])
        
        let items = assetItems
        snapshot.appendSections([ .assets ])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
    }
}

extension IncomingASAAccountInboxAPIDataController {
    
    private func makeItemsForAssetsLoading() -> [IncomingASAItem] {
        return [ .assetLoading ]
    }

    private func makeItemsForAssets(assets: [IncomingASAsRequestDetailResult]?) -> [IncomingASAItem] {
        assets.someArray.compactMap{
            makeItemForAsset(
                $0.asset,
                senders: $0.senders,
                algoGainOnClaim: $0.algoGainOnClaim,
                algoGainOnReject: $0.algoGainOnReject,
                shouldUseFundsBeforeClaiming: $0.shouldUseFundsBeforeClaiming,
                hasInsufficientAlgoForClaiming: $0.hasInsufficientAlgoForClaiming,
                shouldUseFundsBeforeRejecting: $0.shouldUseFundsBeforeRejecting,
                hasInsufficientAlgoForRejecting: $0.hasInsufficientAlgoForRejecting,
                totalAmount: $0.totalAmount
            )
        }
    }
    
    private func makeItemForAsset(
        _ assetDecoration: AssetDecoration?,
        senders: Senders?,
        algoGainOnClaim: UInt64?,
        algoGainOnReject: UInt64?,
        shouldUseFundsBeforeClaiming: Bool,
        hasInsufficientAlgoForClaiming: Bool,
        shouldUseFundsBeforeRejecting: Bool,
        hasInsufficientAlgoForRejecting: Bool,
        totalAmount: UInt64?
    ) -> IncomingASAItem? {
        guard let assetDecoration else {
            return nil
        }
        
        var collectibleAsset: CollectibleAsset? = nil
        
        if assetDecoration.isCollectible {
            collectibleAsset = CollectibleAsset(decoration: assetDecoration)
        }
        
        return makeItemForNonNFTAsset(
            StandardAsset(decoration: assetDecoration),
            collectibleAsset: collectibleAsset,
            senders: senders,
            algoGainOnClaim: algoGainOnClaim,
            algoGainOnReject: algoGainOnReject,
            shouldUseFundsBeforeClaiming: shouldUseFundsBeforeClaiming,
            hasInsufficientAlgoForClaiming: hasInsufficientAlgoForClaiming,
            shouldUseFundsBeforeRejecting: shouldUseFundsBeforeRejecting,
            hasInsufficientAlgoForRejecting: hasInsufficientAlgoForRejecting,
            totalAmount: totalAmount
        )
    }
    
    private func makeItemForNonNFTAsset(
        _ asset: StandardAsset,
        collectibleAsset: CollectibleAsset?,
        senders: Senders?, 
        algoGainOnClaim: UInt64?,
        algoGainOnReject: UInt64?,
        shouldUseFundsBeforeClaiming: Bool,
        hasInsufficientAlgoForClaiming: Bool,
        shouldUseFundsBeforeRejecting: Bool,
        hasInsufficientAlgoForRejecting: Bool,
        totalAmount: UInt64?
    ) -> IncomingASAItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter,
            isAmountHidden: false
        )

        var collectibleAssetItem: CollectibleAssetItem?
        
        if let collectibleAsset {
            collectibleAssetItem = CollectibleAssetItem(
                account: Account(),
                asset: collectibleAsset,
                amountFormatter: assetAmountFormatter,
                showForIncomingASA: true,
                totalAmount: totalAmount
            )
        }
        
        let item = IncomingASAListItem(
            item: assetItem,
            collectibleAssetItem: collectibleAssetItem,
            senders: senders,
            accountAddress: incomingASAsRequestDetail?.address,
            inboxAddress: incomingASAsRequestDetail?.inboxAddress,
            totalAmount: totalAmount,
            algoGainOnClaim: algoGainOnClaim,
            algoGainOnReject: algoGainOnReject,
            shouldUseFundsBeforeClaiming: shouldUseFundsBeforeClaiming,
            hasInsufficientAlgoForClaiming: hasInsufficientAlgoForClaiming,
            shouldUseFundsBeforeRejecting: shouldUseFundsBeforeRejecting,
            hasInsufficientAlgoForRejecting: hasInsufficientAlgoForRejecting
        )
        return .asset(item)
    }
}

extension IncomingASAAccountInboxAPIDataController {
    private func makeUpdatesForNoContent(
        for operation: Updates.Operation
    ) -> Updates {
        var snapshot = Snapshot()
        appendSectionForNoContent(into: &snapshot)
        return Updates(snapshot: snapshot, operation: operation)
    }
    
    private func appendSectionForNoContent(into snapshot: inout Snapshot) {
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.empty],
            toSection: .empty
        )
    }
    
    private func appendSectionForSearchNoContent(into snapshot: inout Snapshot) {
        snapshot.appendSections([.empty])
        snapshot.appendItems(
            [.empty],
            toSection: .empty
        )
    }
}

extension IncomingASAAccountInboxAPIDataController {
    private func publish(updates: Updates) {
        lastSnapshot = updates.snapshot
        publish(event: .didUpdate(updates))
    }

    private func publish(event: IncomingASAListDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event)
        }
    }
}

extension IncomingASAAccountInboxAPIDataController {
    private func createAsyncLoadingQueue() -> AsyncSerialQueue {
        let underlyingQueue = DispatchQueue(
            label: "pera.queue.accountAssets.updates",
            qos: .userInitiated
        )
        return .init(
            name: "accountAssetListAPIDataController.asyncLoadingQueue",
            underlyingQueue: underlyingQueue
        )
    }

    private func createCurrencyFormatter() -> CurrencyFormatter {
        return .init()
    }

    private func createAssetAmountFormatter() -> CollectibleAmountFormatter {
        return .init()
    }
}

extension IncomingASAAccountInboxAPIDataController {
    typealias Updates = IncomingASAListUpdates
    typealias Snapshot = IncomingASAListUpdates.Snapshot
}
