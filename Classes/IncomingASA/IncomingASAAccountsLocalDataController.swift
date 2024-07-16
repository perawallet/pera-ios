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
    
    private(set)var incomingASAsRequestList: IncomingASAsRequestList?
    private let sharedDataController: SharedDataController
    private var lastSnapshot: Snapshot?

    init(
        incomingASAsRequestList: IncomingASAsRequestList?,
        sharedDataController: SharedDataController
    ) {
        self.incomingASAsRequestList = incomingASAsRequestList
        self.sharedDataController = sharedDataController
    }
}

extension IncomingASAAccountsLocalDataController {
    func load() {
        if let results = incomingASAsRequestList?.results,
            results.isNonEmpty,
            results.filter({ ($0.requestCount ?? 0) > 0}).isNonEmpty {
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
        incomingASAsRequestList?.results.forEach { incomingASAsRequestsResult in
            if let address = incomingASAsRequestsResult.address,
               let account = sharedDataController.accountCollection[address]?.value {
                if let count = incomingASAsRequestsResult.requestCount, count > 0 {
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
    typealias Updates = IncomingASAAccountsUpdates
    typealias Snapshot = IncomingASAAccountsUpdates.Snapshot
}
