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
    
    private var nextQuery: IncomingASAsRequestDetailQuery?
    private var lastQuery: IncomingASAsRequestDetailQuery?
    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let api: ALGAPI

    private var nextCursor: String?
    private var incomingASAsRequestDetail: IncomingASAsRequestDetailList?

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
    func load(query: IncomingASAsRequestDetailQuery) {
        api.fetchIncomingASAsRequest(address, with: query) {
            [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let requestList):
                self.incomingASAsRequestDetail = requestList
                reload()
            case .failure(let apiError, _):
                self.publish(event: .didReceiveError(apiError.localizedDescription))
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
        query: IncomingASAsRequestDetailQuery?,
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
        query: IncomingASAsRequestDetailQuery?,
        for operation: Updates.Operation
    ) -> Updates {
        
        if requestsCount == 0 {
            return makeUpdatesForNoContent(for: operation)
        }
        
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
    
    private func makeItemForTitle() -> [IncomingASAItem] {
        let viewModel = IncomingASAAccountInboxHeaderTitleCellViewModel(count: requestsCount)
        return [.title(viewModel)]
    }

    private func makeItemsForAssets(assets: [IncomingASAsRequestDetailResult]?) -> [IncomingASAItem] {
        assets.someArray.compactMap{
            makeItemForAsset(
                $0.asset,
                senders: $0.senders,
                algoGainOnClaim: $0.algoGainOnClaim,
                algoGainOnReject: $0.algoGainOnReject
            )
        }
    }
    
    private func makeItemForAsset(
        _ assetDecoration: AssetDecoration?,
        senders: Senders?,
        algoGainOnClaim: UInt64?,
        algoGainOnReject: UInt64?
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
            algoGainOnReject: algoGainOnReject
        )
    }
    
    private func makeItemForNonNFTAsset(
        _ asset: StandardAsset,
        collectibleAsset: CollectibleAsset?,
        senders: Senders?, 
        algoGainOnClaim: UInt64?,
        algoGainOnReject: UInt64?
    ) -> IncomingASAItem {
        let currency = sharedDataController.currency
        let assetItem = AssetItem(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )

        var collectibleAssetItem: CollectibleAssetItem?
        
        if let collectibleAsset {
            collectibleAssetItem = CollectibleAssetItem(
                account: Account(),
                asset: collectibleAsset,
                amountFormatter: assetAmountFormatter
            )
        }
        
        let item = IncomingASAListItem(
            item: assetItem,
            collectibleAssetItem: collectibleAssetItem,
            senders: senders,
            accountAddress: incomingASAsRequestDetail?.address,
            inboxAddress: incomingASAsRequestDetail?.inboxAddress,
            algoGainOnClaim: algoGainOnClaim,
            algoGainOnReject: algoGainOnReject
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
    
    private func makeUpdatesForSearchNoContent(
        for operation: Updates.Operation
    ) -> Updates {
        var snapshot = Snapshot()
        appendSectionForSearchNoContent(into: &snapshot)
        return Updates(snapshot: snapshot, operation: operation)
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

    private func createMinBalanceCalculator() -> TransactionFeeCalculator {
        return .init(transactionDraft: nil, transactionData: nil, params: nil)
    }
}

extension IncomingASAAccountInboxAPIDataController {
    typealias Updates = IncomingASAListUpdates
    typealias Snapshot = IncomingASAListUpdates.Snapshot
}
