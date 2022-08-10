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

//   WCSessionListLocalDataController.swift

import Foundation
import MacaroonUtils

final class WCSessionListLocalDataController:
    WCSessionListDataController {
    typealias EventHandler = (WCSessionListDataControllerEvent) -> Void

    var eventHandler: EventHandler?

    private let snapshotQueue = DispatchQueue(
        label: "com.algorand.queue.wcSessionListLocalDataController"
    )

    private lazy var sessions: [WCSession] = walletConnector.allWalletConnectSessions

    var dataSource: WCSessionListDataSource!

    private var cachedSessionListItems: [WCSession: WCSessionListItem] = [:]

    var disconnectedSessions: Set<WCSession> = []

    private let walletConnector: WalletConnector
    
    init(
        walletConnector: WalletConnector
    ) {
        self.walletConnector = walletConnector
    }
}

extension WCSessionListLocalDataController {
    func load() {
        if sessions.isEmpty {
            deliverNoContentSnapshot()
        } else {
            deliverContentSnapshot()
        }
    }
}

extension WCSessionListLocalDataController {
    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = Snapshot()

            snapshot.appendSections([ .sessions ])

            self.addSessionItems(&snapshot)

            return snapshot
        }
    }

    private func deliverNoContentSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([ .empty ])
            snapshot.appendItems(
                [ .empty ],
                toSection: .empty
            )
            return snapshot
        }
    }

    private func addSessionItems(
        _ snapshot: inout Snapshot
    ) {
        let assetItems: [WCSessionListItem] = sessions.map {
            let item = makeSessionItem($0)
            self.cachedSessionListItems[item.session!] = item
            return item
        }

        snapshot.appendItems(
            assetItems,
            toSection: .sessions
        )
    }

    private func makeSessionItem(
        _ session: WCSession
    ) -> WCSessionListItem {
        let viewModel = WCSessionItemViewModel(session)

        let item: WCSessionListItem = .session(
            WCSessionListItemContainer(
                session: session,
                viewModel: viewModel
            )
        )
        return item
    }

    func removeSession(
        _ session: WCSession
    ) {
        disconnectedSessions.remove(session)

        let itemToDelete = cachedSessionListItems[session]

        guard let itemToDelete = itemToDelete else {
            return
        }

        cachedSessionListItems.removeValue(forKey: itemToDelete.session!)

        if cachedSessionListItems.isEmpty {
            deliverNoContentSnapshot()
            return
        }

        deliverSnapshot {
            [weak dataSource] in
            guard let dataSource = dataSource else {
                return nil
            }

            var snapshot = dataSource.snapshot()

            snapshot.deleteItems([ itemToDelete ])

            return snapshot
        }
    }

    func addSession(
        _ session: WCSession
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return nil
            }

            var snapshot = self.dataSource.snapshot()

            if snapshot.sectionIdentifiers.contains(.empty) {
                snapshot.deleteSections([ .empty ])
            }

            let viewModel = WCSessionItemViewModel(session)

            let item: WCSessionListItem = .session(
                WCSessionListItemContainer(
                    session: session,
                    viewModel: viewModel
                )
            )

            if !snapshot.sectionIdentifiers.contains(.sessions) {
                snapshot.appendSections([ .sessions ] )
            }

            snapshot.appendItems(
                [item],
                toSection: .sessions
            )

            self.cachedSessionListItems[item.session!] = item

            return snapshot
        }
    }

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
}

extension WCSessionListLocalDataController {
    private func publish(
        _ event: WCSessionListDataControllerEvent
    ) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(event)
        }
    }
}
