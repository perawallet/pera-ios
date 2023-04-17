// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyedAccountSelectionListLocalDataController.swift

import Foundation
import OrderedCollections

final class RekeyedAccountSelectionListLocalDataController: RekeyedAccountSelectionListDataController {
    var eventHandler: ((RekeyedAccountSelectionListDataControllerEvent) -> Void)?

    private lazy var accounts: OrderedDictionary<Index, Account> = [:]
    private lazy var selectedAccounts: OrderedDictionary<Index, Account> = [:]

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.rekeyedAccountSelectionListLocalDataController.updates",
        qos: .userInitiated
    )

    private let sharedDataController: SharedDataController

    private let rekeyedAccounts: [Account]

    init(
        rekeyedAccounts: [Account],
        sharedDataController: SharedDataController
    ) {
        self.rekeyedAccounts = rekeyedAccounts
        self.sharedDataController = sharedDataController
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    func isAccountSelected(at index: Index) -> Bool {
        return selectedAccounts[index] != nil
    }

    var isPrimaryActionEnabled: Bool {
        return !selectedAccounts.isEmpty
    }

    var hasSingleAccount: Bool {
        return accounts.isSingular
    }

    func getAccounts() -> [Account] {
        return rekeyedAccounts
    }

    func getSelectedAccounts() -> [Account] {
        return selectedAccounts.values.elements
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    func selectAccountItem(at index: Index) {
        guard let selectedAccount = accounts[index] else {
            return
        }

        selectedAccounts[index] = selectedAccount
    }

    func unselectAccountItem(at index: Index) {
        selectedAccounts[index] = nil
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return nil }

            var snapshot = Snapshot()

            self.addAccountsSection(
                &snapshot
            )

            return snapshot
        }
    }

    private func addAccountsSection(
        _ snapshot: inout Snapshot
    ) {
        addAccountItems(
            &snapshot,
            accounts: rekeyedAccounts
        )
    }

    private func addAccountItems(
        _ snapshot: inout Snapshot,
        accounts: [Account]
    ) {
        snapshot.appendSections([.accounts])

        addAccounts(
            &snapshot,
            accounts: accounts
        )
    }

    private func addAccounts(
        _ snapshot: inout Snapshot,
        accounts: [Account]
    ) {
        let accountItems: [RekeyedAccountSelectionListItemIdentifier] =
        accounts
            .enumerated()
            .map {
                let account = $0.element
                let viewModel = LedgerAccountViewModel(account)

                let item = RekeyedAccountSelectionListAccountCellItemIdentifier(
                    model: account,
                    viewModel: viewModel
                )

                self.accounts[$0.offset] = account

                return .account(item)
            }

        snapshot.appendItems(
            accountItems,
            toSection: .accounts
        )
    }
}

extension RekeyedAccountSelectionListLocalDataController {
    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot?
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else {
                return
            }

            guard let snapshot = snapshot() else {
                return
            }

            self.publish(.didUpdate(snapshot))
        }
    }

    private func publish(
        _ event: RekeyedAccountSelectionListDataControllerEvent
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
