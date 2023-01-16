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

//   WebImportSuccessScreenLocalDataController.swift

import Foundation
import MacaroonUtils

final class WebImportSuccessScreenLocalDataController:
    WebImportSuccessScreenDataController {
    var eventHandler: ((WebImportSuccessScreenDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.web.import.successScreen.updates",
        qos: .userInitiated
    )

    private let importedAccounts: [AccountInformation]
    private let unimportedAccountCount: Int

    init(
        importedAccounts: [AccountInformation],
        unimportedAccountCount: Int
    ) {
        self.importedAccounts = importedAccounts
        self.unimportedAccountCount = unimportedAccountCount
    }
}

extension WebImportSuccessScreenLocalDataController {
    func load() {
        deliverContentSnapshot()
    }
}

extension WebImportSuccessScreenLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }
            var snapshot = Snapshot()

            snapshot.appendSections([.accounts])

            let importedAccountCount = self.importedAccounts.count
            let unimportedAccountCount = self.unimportedAccountCount

            snapshot.appendItems([.header(importedAccountCount)])
            if unimportedAccountCount > 0 {
                snapshot.appendItems([.missingAccounts(unimportedAccountCount)])
            }

            let accounts = self.importedAccounts.map { accountInformation in
                let account = Account(localAccount: accountInformation)
                return WebImportSuccessListViewItem.account(AccountListItemViewModel(account))
            }
            snapshot.appendItems(accounts)

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

extension WebImportSuccessScreenLocalDataController {
    private func publish(
        _ event: WebImportSuccessScreenDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
