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

//   ExportAccountListLocalDataController.swift

import Foundation

final class ExportAccountListLocalDataController: ExportAccountListDataController {
    var eventHandler: ((ExportAccountListDataControllerEvent) -> Void)?

    private lazy var headerItem: ExportAccountListAccountHeaderItemIdentifier? = nil

    private lazy var accounts: [Index: ExportAccountListAccountCellItemIdentifier] = [:]
    private lazy var selectedAccounts: [Index: ExportAccountListAccountCellItemIdentifier] = [:]

    private let snapshotQueue = DispatchQueue(label: "exportAccountListSnapshot")

    private let sharedDataController: SharedDataController
    
    init(sharedDataController: SharedDataController) {
        self.sharedDataController = sharedDataController
    }
}

extension ExportAccountListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension ExportAccountListLocalDataController {
    func isAccountSelected(atIndex index: Index) -> Bool {
        return selectedAccounts[index] != nil
    }

    var isContinueActionEnabled: Bool {
        return !selectedAccounts.isEmpty
    }

    func getSelectedAccounts() -> [AccountHandle] {
        return selectedAccounts.values.map(\.model)
    }
}

extension ExportAccountListLocalDataController {
    func updateAccountsHeader(
        _ snapshot: inout Snapshot
    ) {
        let viewModel = ExportAccountListAccountsHeaderViewModel(
            accountsCount: accounts.values.count,
            state: getAccountHeaderItemState()
        )

        let updatedItem = ExportAccountListAccountHeaderItemIdentifier(
            viewModel: viewModel
        )

        snapshot.insertItems(
            [.account(.header(updatedItem))],
            beforeItem: .account(.header(headerItem!))
        )
        snapshot.deleteItems([ .account(.header(headerItem!)) ])

        self.headerItem = updatedItem
    }
}

extension ExportAccountListLocalDataController {
    func getAccountHeaderItemState() -> ExportAccountListAccountHeaderItemState {
        if selectedAccounts.isEmpty {
            return .selectAll
        }

        if accounts.values.count == selectedAccounts.values.count {
            return .unselectAll
        }

        return .partialSelection
    }
}

extension ExportAccountListLocalDataController {
    func selectAccountItem(
        _ snapshot: Snapshot,
        atIndex index: Index
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return nil }

            var snapshot = snapshot

            guard let selectedAccount = self.accounts[index] else {
                return nil
            }

            self.selectedAccounts[index] = selectedAccount

            self.updateAccountsHeader(&snapshot)

            snapshot.reloadItems([ .account(.cell(selectedAccount)) ])

            return snapshot
        }
    }

    func unselectAccountItem(
        _ snapshot: Snapshot,
        atIndex index: Index
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return nil }

            var snapshot = snapshot

            guard let unselectedAccount = self.accounts[index] else {
                return nil
            }

            self.selectedAccounts[index] = nil

            self.updateAccountsHeader(&snapshot)

            snapshot.reloadItems([ .account(.cell(unselectedAccount)) ])

            return snapshot
        }
    }

    func selectAllAccountsItems(_ snapshot: Snapshot) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return nil }

            var snapshot = snapshot

            self.selectedAccounts = self.accounts

            self.updateAccountsHeader(&snapshot)

            let accountItems: [ExportAccountListItemIdentifier] =
                self.accounts.values.map {
                    return .account(.cell($0))
                }

            snapshot.reloadItems(
                accountItems
            )

            return snapshot
        }
    }

    func unselectAllAccountsItems(_ snapshot: Snapshot) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return nil }

            var snapshot = snapshot

            self.selectedAccounts = [:]

            self.updateAccountsHeader(&snapshot)

            let accountItems: [ExportAccountListItemIdentifier] =
                self.accounts.values.map {
                    return .account(.cell($0))
                }

            snapshot.reloadItems(
                accountItems
            )

            return snapshot
        }
    }
}

extension ExportAccountListLocalDataController {
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
        snapshot.appendSections([.accounts])

        let accounts =
            sharedDataController
                .sortedAccounts()
                .filter {
                    $0.value.type != .watch
                }

        addAccountsHeader(
            &snapshot,
            accounts: accounts
        )
        addAccounts(
            &snapshot,
            accounts: accounts
        )
    }

    private func addAccountsHeader(
        _ snapshot: inout Snapshot,
        accounts: [AccountHandle]
    ) {
        let viewModel = ExportAccountListAccountsHeaderViewModel(
            accountsCount: accounts.count,
            state: getAccountHeaderItemState()
        )
        let item = ExportAccountListAccountHeaderItemIdentifier(
            viewModel: viewModel
        )

        self.headerItem = item

        snapshot.appendItems(
            [ .account(.header(item)) ],
            toSection: .accounts
        )
    }

    private func addAccounts(
        _ snapshot: inout Snapshot,
        accounts: [AccountHandle]
    ) {
        let accountItems: [ExportAccountListItemIdentifier] =
        accounts
            .enumerated()
            .map {
                let accountHandle = $0.element
                let account = accountHandle.value
                let draft = IconWithShortAddressDraft(account)
                let viewModel = AccountPreviewViewModel(draft)

                let item = ExportAccountListAccountCellItemIdentifier(
                    model: accountHandle,
                    viewModel: viewModel
                )

                self.accounts[$0.offset] = item

                return .account(.cell(item))
            }

        snapshot.appendItems(
            accountItems,
            toSection: .accounts
        )
    }
}

extension ExportAccountListLocalDataController {
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
        _ event: ExportAccountListDataControllerEvent
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
