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

//   IncomingASAAccountsLocalDataController.swift

import Foundation
import MacaroonUtils

// MARK: - LocalDataController
final class IncomingASAAccountsLocalDataController:
    IncomingASAAccountsDataController,
    SharedDataControllerObserver {
    
    var eventHandler: ((IncomingASAAccountsDataControllerEvent) -> Void)?
    
    private(set)var incommingASAsRequestList: IncommingASAsRequestList?
    private let sharedDataController: SharedDataController
    private var lastSnapshot: Snapshot?

    init(
        incommingASAsRequestList: IncommingASAsRequestList?,
        sharedDataController: SharedDataController
    ) {
        self.incommingASAsRequestList = incommingASAsRequestList
        self.sharedDataController = sharedDataController
    }
}

extension IncomingASAAccountsLocalDataController {
    func load() {
        if let results = incommingASAsRequestList?.results, results.isNonEmpty {
            deliverUpdatesForContent(for: .refresh)
        } else {
            deliverUpdatesForNoContent(for: .refresh)
        }
    }
}


extension IncomingASAAccountsLocalDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            load()
        }
    }
}

extension IncomingASAAccountsLocalDataController {

    private func deliverUpdatesForContent(
        for operation: Updates.Operation
    ) {
        let updates = makeUpdatesForContent(
            for: operation
        )
        self.publish(updates: updates)
    }

    private func makeUpdatesForContent(
        for operation: Updates.Operation
    ) -> Updates {
        var snapshot = Snapshot()
        appendSectionForAccounts(into: &snapshot)
        return Updates(snapshot: snapshot, operation: operation)
    }
    
    private func appendSectionForAccounts(into snapshot: inout Snapshot) {
        let items = makeItemForAccountItem()
        snapshot.appendSections([ .accounts ])
        snapshot.appendItems(
            items,
            toSection: .accounts
        )
    }
}


extension IncomingASAAccountsLocalDataController {
    
    private func deliverUpdatesForNoContent(
        for operation: Updates.Operation
    ) {
        let updates = makeUpdatesForNoContent(
            for: operation
        )
        self.publish(updates: updates)
    }

    private func makeUpdatesForNoContent(
        for operation: Updates.Operation
    ) -> Updates {
        var snapshot = Snapshot()
        appendSectionForNoContentAccounts(into: &snapshot)
        return Updates(snapshot: snapshot, operation: operation)
    }
    
    private func appendSectionForNoContentAccounts(into snapshot: inout Snapshot) {
        let items = makeItemForAccountItem()
        snapshot.appendSections([ .empty ])
        snapshot.appendItems(
            [.empty],
            toSection: .empty
        )
    }
}

extension IncomingASAAccountsLocalDataController {

    private func makeItemForAccountItem() -> [IncomingASAAccountsItem] {
        var accountsItems: [IncomingASAAccountsItem] = []
        incommingASAsRequestList?.results.forEach { incommingASAsRequestsResult in
            if let address = incommingASAsRequestsResult.address,
               let account = sharedDataController.accountCollection[address]?.value {
                if let count = incommingASAsRequestsResult.requestCount, count > 0 {
                    accountsItems.append(
                        IncomingASAAccountsItem.account(IncomingASAAccountCellViewModel.init(account, incomingRequestCount: count))
                    )
                }
            }
        }
        return accountsItems
    }
}

extension IncomingASAAccountsLocalDataController {
    private func publish(updates: Updates) {
        lastSnapshot = updates.snapshot
        publish(event: .didUpdate(updates))
    }

    private func publish(event: IncomingASAAccountsDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event)
        }
    }
}

extension IncomingASAAccountsLocalDataController {

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

extension IncomingASAAccountsLocalDataController {
    typealias Updates = IncomingASAAccountsUpdates
    typealias Snapshot = IncomingASAAccountsUpdates.Snapshot
}
