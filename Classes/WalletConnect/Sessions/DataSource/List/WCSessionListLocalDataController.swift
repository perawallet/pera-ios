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

final class WCSessionListLocalDataController: WCSessionListDataController {
    typealias EventHandler = (WCSessionListDataControllerEvent) -> Void

    var eventHandler: EventHandler?
    
    private let sharedDataController: SharedDataController

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.wcSessions.updates",
        qos: .userInitiated
    )

    private var lastSnapshot: Snapshot? = nil
    private var disconnectedSessions: Set<WCSessionDraft> = []

    private var cachedSessionListItems: [WCSessionDraft: WCSessionListItem] = [:]

    private var sessions: [WCSessionDraft]

    var shouldShowDisconnectAllAction: Bool {
        let sessions = peraConnect.walletConnectCoordinator.getSessions()
        return sessions.count > 1
    }

    private let analytics: ALGAnalytics
    private let peraConnect: PeraConnect

    init(
        sharedDataController: SharedDataController,
        analytics: ALGAnalytics,
        peraConnect: PeraConnect
    ) {
        self.sharedDataController = sharedDataController
        self.analytics = analytics
        self.peraConnect = peraConnect
        self.sessions = peraConnect.walletConnectCoordinator.getSessions()
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

    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return nil
            }

            var snapshot = Snapshot()

            snapshot.appendSections([ .sessions ])

            self.addSessionItems(&snapshot)

            return snapshot
        }
    }

    private func addSessionItems(_ snapshot: inout Snapshot) {
        let sessionItems: [WCSessionListItem] = sessions.map {
            let item = makeSessionItem($0)

            if let session = item.session {
                cachedSessionListItems[session] = item
            }

            return item
        }

        snapshot.appendItems(
            sessionItems,
            toSection: .sessions
        )
    }

    private func makeSessionItem(_ draft: WCSessionDraft) -> WCSessionListItem {
        let viewModel = WCSessionItemViewModel(draft)
        let item: WCSessionListItem = .session(
            WCSessionListItemContainer(
                session: draft,
                viewModel: viewModel
            )
        )
        return item
    }

    private func removeSessionItem(
        _ snapshot: Snapshot,
        draft: WCSessionDraft
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return nil
            }

            self.disconnectedSessions.remove(draft)

            self.stopLoadingIfNeeded()

            let itemToDelete = self.cachedSessionListItems[draft]

            guard let itemToDelete = itemToDelete else {
                return nil
            }

            self.cachedSessionListItems.removeValue(forKey: draft)

            if self.cachedSessionListItems.isEmpty {
                self.deliverNoContentSnapshot()
                return nil
            }

            var snapshot = snapshot

            snapshot.deleteItems([ itemToDelete ])

            return snapshot
        }
    }

    func removeSessionItemFromList(
        _ snapshot: Snapshot,
        draft: WCSessionDraft
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self else { return nil }

            let itemToDelete = self.cachedSessionListItems[draft]

            self.cachedSessionListItems.removeValue(forKey: draft)

            if self.cachedSessionListItems.isEmpty {
                self.deliverNoContentSnapshot()
                return nil
            }

            guard let itemToDelete else {  return nil  }

            var snapshot = snapshot
            snapshot.deleteItems([ itemToDelete ])
            return snapshot
        }
    }

    func addSessionItem(
        _ snapshot: Snapshot,
        draft: WCSessionDraft
    ) {
        deliverSnapshot {
            [weak self] in
            guard let self = self else {
                return Snapshot()
            }

            var snapshot = snapshot

            if snapshot.sectionIdentifiers.contains(.empty) {
                snapshot.deleteSections([ .empty ])
            }

            let viewModel = WCSessionItemViewModel(draft)
            let item: WCSessionListItem = .session(
                WCSessionListItemContainer(
                    session: draft,
                    viewModel: viewModel
                )
            )

            if !snapshot.sectionIdentifiers.contains(.sessions) {
                snapshot.appendSections([ .sessions ] )
            }

            snapshot.insertItem(
                item,
                to: .sessions,
                at: 0
            )

            if let session = item.session {
                self.cachedSessionListItems[session] = item
            }

            return snapshot
        }
    }

    private func deliverSnapshot(_ snapshot: @escaping () -> Snapshot?) {
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
    func disconnectAllSessions(_ snapshot: Snapshot) {
        publish(.didStartDisconnectingFromSessions)

        lastSnapshot = snapshot

        let allSessions = peraConnect.walletConnectCoordinator.getSessions()

        disconnectedSessions = Set(allSessions)

        peraConnect.disconnectFromAllSessions()
    }
}

extension WCSessionListLocalDataController {
    private func stopLoadingIfNeeded() {
        if disconnectedSessions.isEmpty {
            publish(.didDisconnectFromSessions)
        }
    }
}

extension WCSessionListLocalDataController {
    func startObservingEvents() {
        startObservingPeraConnectEvents()
    }

    private func startObservingPeraConnectEvents() {
        peraConnect.eventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .didDisconnectFromV1(let session):
                asyncMain {
                    [weak self] in
                    guard let self else { return }
                    analytics.track(
                        .wcSessionDisconnected(
                            dappName: session.peerMeta.name,
                            dappURL: session.peerMeta.url.absoluteString,
                            address: session.walletMeta?.accounts?.first
                        )
                    )

                    guard let lastSnapshot else {  return  }

                    let draft = WCSessionDraft(wcV1Session: session)
                    removeSessionItem(
                        lastSnapshot,
                        draft: draft
                    )
                }
            case .didDisconnectFromV1Fail(let session, let error):
                asyncMain {
                    [weak self] in
                    guard let self else { return }
                    switch error {
                    case .failedToDisconnectInactiveSession:
                        guard let lastSnapshot else {  return  }

                        let draft = WCSessionDraft(wcV1Session: session)
                        removeSessionItem(
                            lastSnapshot,
                            draft: draft
                        )
                    case .failedToDisconnect:
                        let draft = WCSessionDraft(wcV1Session: session)
                        disconnectedSessions.remove(draft)

                        stopLoadingIfNeeded()

                        publish(.didFailDisconnectingFromSession)
                    default: break
                    }
                }
            case .didDisconnectFromV2(let session):
                asyncMain {
                    [weak self] in
                    guard let self else { return }

                    guard let lastSnapshot else { return  }

                    let draft = WCSessionDraft(wcV2Session: session)
                    removeSessionItem(
                        lastSnapshot,
                        draft: draft
                    )
                }
            case .didDisconnectFromV2Fail(let session, _):
                asyncMain {
                    [weak self] in
                    guard let self else { return }

                    let draft = WCSessionDraft(wcV2Session: session)
                    disconnectedSessions.remove(draft)

                    stopLoadingIfNeeded()

                    publish(.didFailDisconnectingFromSession)
                }
            case .sessionsV2:
                sessions = peraConnect.walletConnectCoordinator.getSessions()
                cachedSessionListItems = [:]

                disconnectedSessions = []
                stopLoadingIfNeeded()

                load()
            default:
                break
            }
        }
    }
}

extension WCSessionListLocalDataController {
    private func publish(_ event: WCSessionListDataControllerEvent) {
        asyncMain {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(event)
        }
    }
}
