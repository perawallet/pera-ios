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
    IncomingASAAccountInboxDataController,
    SharedDataControllerObserver {
    var eventHandler: ((IncomingASAListDataControllerEvent) -> Void)?
    
    private(set)var requestsCount: Int
    private(set)var address: String
    
    private lazy var asyncLoadingQueue = createAsyncLoadingQueue()

    private lazy var currencyFormatter = createCurrencyFormatter()
    private lazy var assetAmountFormatter = createAssetAmountFormatter()
    private lazy var minBalanceCalculator = createMinBalanceCalculator()

    private var accountNotBackedUpWarningViewModel: AccountDetailAccountNotBackedUpWarningModel?
    
    private var nextQuery: IncommingASAsRequestDetailQuery?
    private var lastQuery: IncommingASAsRequestDetailQuery?
    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let api: ALGAPI

    private var nextCursor: String?
    private var incommingASAsRequestDetail: IncommingASAsRequestDetailList?

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

    deinit {
        sharedDataController.remove(self)
    }
}

extension IncomingASAAccountInboxAPIDataController {
    func load(query: IncommingASAsRequestDetailQuery) {
        api.fetchIncommingASAsRequest(address, with: query) {
            [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let requestList):
                self.incommingASAsRequestDetail = requestList
                reload()
            case .failure(let apiError, _):
                // TODO:  Handle Error Delegate
                break
            }
        }
        
        nextQuery = query

        lastQuery = query
        nextQuery = nil
        sharedDataController.add(self)
    }

    func reload() {
        let task = AsyncTask {
            [weak self] completionBlock in
            guard let self else { return }

            defer {
                completionBlock()
            }

            self.deliverUpdatesForContent(
                when: { self.nextQuery == nil },
                query: self.lastQuery,
                for: .refresh
            )
        }
        asyncLoadingQueue.add(task)
    }
}

extension IncomingASAAccountInboxAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            reload()
        }
    }
}

extension IncomingASAAccountInboxAPIDataController {

    private func makeUpdatesForLoading(for operation: Updates.Operation) -> Updates {
        var snapshot = Snapshot()
        appendSectionForTitle(into: &snapshot)
        return Updates(snapshot: snapshot, operation: operation)
    }

    private func deliverUpdatesForContent(
        when condition: () -> Bool,
        query: IncommingASAsRequestDetailQuery?,
        for operation: Updates.Operation
    ) {
        let updates = makeUpdatesForContent(
            query: query,
            for: operation
        )

        if !condition() { return }

        self.lastQuery = query
        self.nextQuery = nil
        self.publish(updates: updates)
    }

    private func makeUpdatesForContent(
        query: IncommingASAsRequestDetailQuery?,
        for operation: Updates.Operation
    ) -> Updates {
        var snapshot = Snapshot()
        appendSectionForTitle(into: &snapshot)
        appendSectionsForAssets(
            query: query,
            into: &snapshot
        )
        return Updates(snapshot: snapshot, operation: operation)
    }
}

extension IncomingASAAccountInboxAPIDataController {
    
    private func appendSectionForTitle(into snapshot: inout Snapshot) {
        let items = makeItemForTitle()
        snapshot.appendSections([.title])
        snapshot.appendItems(
            items,
            toSection: .title
        )
    }

    private func appendSectionsForAssets(
        query: IncommingASAsRequestDetailQuery?,
        into snapshot: inout Snapshot
    ) {
        let assetItems = makeItemsForAssets(assets: incommingASAsRequestDetail?.results ?? [])
        
        let items = assetItems
        snapshot.appendSections([ .assets ])
        snapshot.appendItems(
            items,
            toSection: .assets
        )
    }
}

extension IncomingASAAccountInboxAPIDataController {

    
    private func makeItemForTitle() -> [IncomingASAItem] {
        let viewModel = IncomingASAAccountInboxHeaderTitleCellViewModel(count: requestsCount)
        return [.title(viewModel)]
    }

    private func makeItemsForAssets(assets: [IncommingASAsRequestDetailResult]?) -> [IncomingASAItem] {
        let standardAssets = assets?.compactMap { item in
            item.asset.map { StandardAsset(decoration: $0) }
        }

        var assetItems: [IncomingASAItem] = standardAssets.someArray.enumerated().compactMap {
            (index,asset) in
            return makeItemForAsset(asset, senders: assets?[index].senders)
        }
        return assetItems
    }

    private func makeItemForAsset(_ asset: Asset, senders: Senders?) -> IncomingASAItem? {
        switch asset {
        case let nonNFTAsset as StandardAsset: return makeItemForNonNFTAsset(nonNFTAsset, senders: senders)
        case let nftAsset as CollectibleAsset: return makeItemForNFTAsset(nftAsset, senders: senders)
        case let algoAsset as Algo: return makeItemForAlgoAsset(algoAsset, senders: senders)
        default: return nil
        }
    }

    private func makeItemForAlgoAsset(_ algoAsset: Algo, senders: Senders?) -> IncomingASAItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: algoAsset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let item = IncomingASAListItem(item: assetItem, senders: senders, accountAddress: incommingASAsRequestDetail?.address)
        return .asset(item)
    }

    private func makeItemForNonNFTAsset(_ asset: StandardAsset, senders: Senders?) -> IncomingASAItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
        let item = IncomingASAListItem(item: assetItem, senders: senders, accountAddress: incommingASAsRequestDetail?.address)
        return .asset(item)
    }

    private func makeItemForNFTAsset(_ asset: CollectibleAsset, senders: Senders?) -> IncomingASAItem {
        let collectibleAssetItem = CollectibleAssetItem(
            account: Account(),
            asset: asset,
            amountFormatter: assetAmountFormatter
        )
        let item = IncomingASACollectibleAssetListItem(item: collectibleAssetItem, senders: senders)
        return .collectibleAsset(item)
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

    private func createMinBalanceCalculator() -> TransactionFeeCalculator {
        return .init(transactionDraft: nil, transactionData: nil, params: nil)
    }
}

extension IncomingASAAccountInboxAPIDataController {
    typealias Updates = IncomingASAListUpdates
    typealias Snapshot = IncomingASAListUpdates.Snapshot
}
