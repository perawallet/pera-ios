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

//   SortAccountListLocalDataController.swift

import Foundation

final class SortAccountListLocalDataController:
    SortAccountListDataController {
    var eventHandler: ((SortAccountListDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(
        label: "sortAccountListSnapshot"
    )

    private var accountsSortings: [AccountSorting] = [
        AccountSortingWithAlphabetically(.ascending),
        AccountSortingWithAlphabetically(.descending),
        AccountSortingWithValue(.descending),
        AccountSortingWithValue(.ascending),
        AccountSortingWithManually()
    ]

    private lazy var store = AccountSortingStore()

    lazy var selectedAccountSorting: AccountSorting = accountsSortings.first(
        matching: (\.id, store.accountSortingID)
    ) ?? AccountSortingWithManually()

    var unorderedAccounts: [AccountHandle]
    lazy var accounts: [AccountHandle] = unorderedAccounts

    weak var session: Session?
    weak var sharedDataController: SharedDataController?

    init(
        session: Session,
        sharedDataController: SharedDataController
    ) {
        self.session = session
        self.sharedDataController = sharedDataController

        unorderedAccounts = sharedDataController
            .accountCollection
            .sorted()
    }

    deinit {
        storeOptionIfNeeeded()
    }
}

extension SortAccountListLocalDataController {
    func load() {
        deliverContentSnapshot()
    }

    func selectItem(
        at indexPath: IndexPath
    ) {
        guard let accountSorting = accountsSortings[safe: indexPath.item] else {
            return
        }

        if selectedAccountSorting.id == accountSorting.id {
            return
        }

        /// <note>
        /// Resetting the account order to initial order, if manually sort option is deselected after order is changed.
        resetOrderIfNeeded(accountSorting)

        selectedAccountSorting = accountSorting

        deliverContentSnapshot()
    }

    func moveItem(
        from source: IndexPath,
        to destination: IndexPath
    ) {
        let movedObject = accounts[source.row]
        accounts.remove(at: source.row)
        accounts.insert(movedObject, at: destination.row)
    }

    func reorder() {
        let sortedAccounts =
        selectedAccountSorting.sort(accounts)

        for (index, account) in sortedAccounts.enumerated() {
            updateAccountPreferredOrder(
                account,
                withIndex: index
            )
        }
    }

    private func updateAccountPreferredOrder(
        _ account: AccountHandle,
        withIndex index: Int
    ) {
        guard let session = session else {
            return
        }

        let type: AccountType = .standard // <todo>: Type will be removed.
        let watchAccountOrderOffset = 1000
        let newAccountOrder = type == .watch ? index + watchAccountOrderOffset : index
        sharedDataController?.accountCollection[account.value.address]?.value.preferredOrder = newAccountOrder
        account.value.preferredOrder = newAccountOrder
        session.authenticatedUser?.updateLocalAccount(account.value)
    }

    private func resetOrderIfNeeded(
        _ accountSorting: AccountSorting
    ) {
        if !(accountSorting is AccountSortingWithManually),
           selectedAccountSorting is AccountSortingWithManually {
            accounts = unorderedAccounts
        }
    }

    private func storeOptionIfNeeeded() {
        if selectedAccountSorting.id != store.accountSortingID {
            store.accountSortingID = selectedAccountSorting.id
        }
    }
}

extension SortAccountListLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            self.addSortContent(&snapshot)

            if self.selectedAccountSorting is AccountSortingWithManually {
                self.addOrderContent(&snapshot)
            }

            return snapshot
        }
    }

    private func addSortContent(
        _ snapshot: inout Snapshot
    ) {
        var items: [SortAccountListItem] = []

        accountsSortings.forEach { option in
            let item: SortAccountListItem = .sort(
                SelectionValue(
                    value: SingleSelectionViewModel(
                        title: option.title,
                        isSelected: option.id == selectedAccountSorting.id
                    ),
                    isSelected: option.id == selectedAccountSorting.id
                )
            )

            items.append(item)
        }
        
        snapshot.appendSections([.sort])
        snapshot.appendItems(
            items,
            toSection: .sort
        )
    }

    private func addOrderContent(
        _ snapshot: inout Snapshot
    ) {
        var items: [SortAccountListItem] = []

        accounts.forEach { account in
            let accountNameViewModel = AccountNameViewModel(account: account.value)
            let preview = CustomAccountPreview(accountNameViewModel)

            let item: SortAccountListItem = .order(
                .cell(
                    AccountPreviewViewModel(preview)
                )
            )
            items.append(item)
        }

        snapshot.appendSections([.order])
        snapshot.appendItems(
            items,
            toSection: .order
        )
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else {
                return
            }

            self.publish(.didUpdate(snapshot()))
        }
    }
}

extension SortAccountListLocalDataController {
    private func publish(
        _ event: SortAccountListDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else {
                return
            }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}

struct AccountSortingStore: Storable {
    typealias Object = Any

    var accountSortingID: String? {
        get {
            return userDefaults.string(forKey: accountSortingIDKey)
        }
        set {
            userDefaults.set(newValue, forKey: accountSortingIDKey)
            userDefaults.synchronize()
        }
    }

    private let accountSortingIDKey = "com.algorand.store.peraApp.accountSortingID"
}
