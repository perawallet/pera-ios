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

//   WCSessionDetailLocalDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class WCSessionDetailLocalDataController: WCSessionDetailDataController {
    var eventHandler: ((WCSessionDetailDataControllerEvent) -> Void)?

    private lazy var updatesQueue = makeUpdatesQueue()

    /// <todo>
    /// We can have some sort of UI cache and manage it outside of the scope of this type.
    private(set) var sessionProfileViewModel: WCSessionProfileViewModel?
    private(set) lazy var wcV1SessionBadgeViewModel: WCV1SessionBadgeViewModel? = .init()
    var sessionInfoViewModel: WCSessionInfoViewModel?

    private(set) var sessionConnectedAccountsHeaderViewModel: WCSessionConnectedAccountsHeaderViewModel?

    private(set) var connectedAccountListItemViewModelsCache: [PublicKey: AccountListItemViewModel] = [:]

    subscript(address: PublicKey) -> AccountListItemViewModel? {
        return findViewModel(forAddress:  address)
    }

    private(set) var sessionAdvancedPermissionsHeaderViewModel: WCSessionAdvancedPermissionsHeaderViewModel?

    private var wcSessionSupportedMethodsAdvancedPermissionViewModel: WCSessionSupportedMethodsAdvancedPermissionViewModel?
    private var wcSessionSupportedEventsAdvancedPermissionViewModel: WCSessionSupportedEventsAdvancedPermissionViewModel?

    subscript(permission: AdvancedPermission) -> PrimaryTitleViewModel? {
        return findViewModel(forPermission: permission)
    }

    private let sharedDataController: SharedDataController

    init(sharedDataController: SharedDataController) {
        self.sharedDataController = sharedDataController
    }
}

extension WCSessionDetailLocalDataController {
    func load() {
        updatesQueue.async {
            [weak self] in
            guard let self else { return }

            deliverUpdatesForProfile()
            deliverUpdatesForWCV1BadgeIfNeeded()
            deliverUpdatesForConnectionInfo()
            deliverUpdatesForConnectedAccounts()
            deliverUpdatesForAdvancedPermissions()
        }
    }
}

extension WCSessionDetailLocalDataController {
    var isPrimaryActionEnabled: Bool {
        return false /// <todo> Remove mock data.
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForProfile() {
        var snapshot = SectionSnapshot()
        appendItemsForProfile(into: &snapshot)

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .profile
        )
        publishUpdates(update)
    }

    private func appendItemsForProfile(into snapshot: inout SectionSnapshot) {
        let items = makeItemsForProfile()
        snapshot.append(items)
    }

    private func makeItemsForProfile() -> [ItemIdentifier] {
        sessionProfileViewModel = WCSessionProfileViewModel()
        return [ .profile ]
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForWCV1BadgeIfNeeded() {
        /// <todo> Add check for wc v1 session

        var snapshot = SectionSnapshot()
        appendItemsForWCV1Badge(into: &snapshot)

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .wcV1Badge
        )
        publishUpdates(update)
    }

    private func appendItemsForWCV1Badge(into snapshot: inout SectionSnapshot) {
        let items = makeItemsForWCV1Badge()
        snapshot.append(items)
    }

    private func makeItemsForWCV1Badge() -> [ItemIdentifier] {
        wcV1SessionBadgeViewModel = WCV1SessionBadgeViewModel()
        return [ .wcV1Badge ]
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForConnectionInfo() {
        var snapshot = SectionSnapshot()
        appendItemsForConnectionInfo(into: &snapshot)

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .connectionInfo
        )
        publishUpdates(update)
    }

    private func appendItemsForConnectionInfo(into snapshot: inout SectionSnapshot) {
        let items = makeItemsForConnectionInfo()
        snapshot.append(items)
    }

    private func makeItemsForConnectionInfo() -> [ItemIdentifier] {
        sessionInfoViewModel = WCSessionInfoViewModel()
        return [ .connectionInfo ]
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForConnectedAccounts() {
        sessionConnectedAccountsHeaderViewModel = .init()

        var snapshot = SectionSnapshot()
        appendItemsForConnectedAccounts(into: &snapshot)

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .connectedAccounts
        )
        publishUpdates(update)
    }

    private func appendItemsForConnectedAccounts(into snapshot: inout SectionSnapshot) {
        let items = makeItemsForConnectedAccounts()
        snapshot.append(items)
    }

    private func makeItemsForConnectedAccounts() -> [ItemIdentifier] {
        let accounts = sharedDataController.sortedAccounts() /// <todo> For mocking purposes
        return accounts.map { .connectedAccount(makeItem(for: $0)) }
    }

    private func makeItem(for account: AccountHandle) -> WCSessionDetail.ConnectedAccountItem {
        saveToCache(account)
        return .init(address: account.value.address)
    }
}

extension WCSessionDetailLocalDataController {
    private func deliverUpdatesForAdvancedPermissions() {
        var snapshot = SectionSnapshot()
        appendItemsForAdvancedPermissions(into: &snapshot)

        let update = SectionSnapshotUpdate(
            snapshot: snapshot,
            section: .advancedPermissions
        )
        publishUpdates(update)
    }

    private func appendItemsForAdvancedPermissions(into snapshot: inout SectionSnapshot) {
        let headerItem = makeItemsForAdvancedPermissionHeader()
        snapshot.append([headerItem])

        let cellItems = makeItemsForAdvancedPermissionCells()
        snapshot.append(
            cellItems,
            to: headerItem
        )
    }

    private func makeItemsForAdvancedPermissionHeader() -> ItemIdentifier {
        sessionAdvancedPermissionsHeaderViewModel = .init()
        return .advancedPermission(.header)
    }

    private func makeItemsForAdvancedPermissionCells() -> [ItemIdentifier] {
        let permissions: [AdvancedPermission] = [ .supportedMethods, .supportedEvents] /// <todo> For mocking purposes
        return permissions.map { .advancedPermission(makeItem(for: $0)) }
    }

    private func makeItem(for permission: AdvancedPermission) -> WCSessionDetail.AdvancedPermissionItem {
        saveToCache(permission)
        return .cell(.init(permission: permission))
    }
}

extension WCSessionDetailLocalDataController {
    private func publishUpdates(_ update: SectionSnapshotUpdate?) {
        guard let update else { return }

        publish(event: .didUpdate(update))
    }

    private func publish(event: WCSessionDetailDataControllerEvent) {
        asyncMain { [weak self] in
            guard let self else { return }
            self.eventHandler?(event)
        }
    }
}

extension WCSessionDetailLocalDataController {
    private func findViewModel(forAddress address: PublicKey) -> AccountListItemViewModel? {
        return connectedAccountListItemViewModelsCache[address]
    }

    private func saveToCache(_ connectedAccount: AccountHandle) {
        let item = WCSessionDetailConnectedAccountItem(account: connectedAccount)
        connectedAccountListItemViewModelsCache[connectedAccount.value.address] = AccountListItemViewModel(item)
    }
}

extension WCSessionDetailLocalDataController {
    private func findViewModel(forPermission permission: AdvancedPermission) -> PrimaryTitleViewModel? {
        switch permission {
        case .supportedMethods: return wcSessionSupportedMethodsAdvancedPermissionViewModel
        case .supportedEvents: return wcSessionSupportedEventsAdvancedPermissionViewModel
        }
    }

    private func saveToCache(_ permission: AdvancedPermission) {
        switch permission {
        case .supportedMethods:
            wcSessionSupportedMethodsAdvancedPermissionViewModel = .init()
        case .supportedEvents:
            wcSessionSupportedEventsAdvancedPermissionViewModel = .init()
        }
    }
}

extension WCSessionDetailLocalDataController {
    private func makeUpdatesQueue() -> DispatchQueue {
        let queue = DispatchQueue(
            label: "pera.queue.wcSessionDetail.updates",
            qos: .userInitiated
        )
        return queue
    }
}
