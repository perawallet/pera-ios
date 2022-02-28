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
//   SelectAccountAPIDataController.swift

import Foundation
import MacaroonUtils

final class SelectAccountAPIDataController:
    SelectAccountDataController,
    SharedDataControllerObserver {
    var eventHandler: ((SelectAccountDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?

    private let sharedDataController: SharedDataController
    private let snapshotQueue = DispatchQueue(label: "com.algorand.queue.selectAccountDataController")
    private let transactionAction: TransactionAction

    init(
        _ sharedDataController: SharedDataController,
        transactionAction: TransactionAction
    ) {
        self.sharedDataController = sharedDataController
        self.transactionAction = transactionAction
    }

    deinit {
        sharedDataController.remove(self)
    }

}

extension SelectAccountAPIDataController {
    func load() {
        sharedDataController.add(self)
    }
}

extension SelectAccountAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didBecomeIdle:
            deliverInitialSnapshot()
        case .didStartRunning(let isFirst):
            if isFirst ||
               lastSnapshot == nil {
                deliverInitialSnapshot()
            }
        case .didFinishRunning:
            deliverContentSnapshot()
        }
    }
}

extension SelectAccountAPIDataController {
    private func deliverInitialSnapshot() {
        if sharedDataController.isPollingAvailable {
            deliverLoadingSnapshot()
        } else {
            deliverNoContentSnapshot()
        }
    }

    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.loading("1")), .empty(.loading("2"))],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot() {
        if sharedDataController.accountCollection.isEmpty {
            deliverNoContentSnapshot()
            return
        }

        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var accounts: [AccountHandle] = []
            var accountItems: [SelectAccountListViewItem] = []

            let currency = self.sharedDataController.currency
            let calculator = ALGPortfolioCalculator()

            self.sharedDataController.accountCollection
                .sorted()
                .forEach { accountHandle in
                    let isWatchAccount = accountHandle.value.type == .watch

                    if isWatchAccount {
                        return
                    }

                    let cellItem: SelectAccountListViewItem

                    if self.transactionAction == .buyAlgo {
                        let algoAccount = CustomAccountPreview(AlgoAccountViewModel(accountHandle.value))

                        cellItem = .account(AccountPreviewViewModel(algoAccount), accountHandle)
                    } else {
                        let accountPortfolio =
                            AccountPortfolio(account: accountHandle, currency: currency, calculator: calculator)

                        cellItem = .account(AccountPreviewViewModel(accountPortfolio), accountHandle)
                    }

                    accounts.append(accountHandle)
                    accountItems.append(cellItem)
                }

            var snapshot = Snapshot()

            snapshot.appendSections([.accounts])

            if !accounts.isEmpty {
                snapshot.appendItems(
                    accountItems,
                    toSection: .accounts
                )
            }

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

extension SelectAccountAPIDataController {
    private func publish(
        _ event: SelectAccountDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            
            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
