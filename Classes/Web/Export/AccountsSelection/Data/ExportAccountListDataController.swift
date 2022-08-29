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

//   ExportAccountListDataController.swift

import Foundation
import UIKit

protocol ExportAccountListDataController: AnyObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ExportAccountListSectionIdentifier, ExportAccountListItemIdentifier>

    var eventHandler: ((ExportAccountListDataControllerEvent) -> Void)? { get set }

    var isContinueActionEnabled: Bool { get }

    func load()

    func getSelectedAccounts() -> [AccountHandle]
    
    func getAccountHeaderItemState() -> ExportAccountListAccountHeaderItemState

    typealias Index = Int
    func selectAccountItem(
        _ snapshot: Snapshot,
        atIndex index: Index
    )
    func unselectAccountItem(
        _ snapshot: Snapshot,
        atIndex index: Index
    )
    func selectAllAccountsItems(_ snapshot: Snapshot)
    func unselectAllAccountsItems(_ snapshot: Snapshot)
    func isAccountSelected(atIndex index: Index) -> Bool
}

enum ExportAccountListSectionIdentifier:
    Hashable {
    case accounts
}

enum ExportAccountListItemIdentifier: Hashable {
    case account(ExportAccountListAccountItemIdentifier)
}

enum ExportAccountListAccountItemIdentifier: Hashable {
    case header(ExportAccountListAccountHeaderItemIdentifier)
    case cell(ExportAccountListAccountCellItemIdentifier)
}

struct ExportAccountListAccountHeaderItemIdentifier:
    Hashable {
    private let id = UUID()
    private(set) var viewModel: ExportAccountListAccountsHeaderViewModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (
        lhs: ExportAccountListAccountHeaderItemIdentifier,
        rhs: ExportAccountListAccountHeaderItemIdentifier
    ) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ExportAccountListAccountCellItemIdentifier:
    Hashable {
    private(set) var model: AccountHandle
    private(set) var viewModel: AccountPreviewViewModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(model.value.address)
    }

    static func == (
        lhs: ExportAccountListAccountCellItemIdentifier,
        rhs: ExportAccountListAccountCellItemIdentifier
    ) -> Bool {
        return lhs.model.value.address == rhs.model.value.address
    }
}

enum ExportAccountListDataControllerEvent {
    case didUpdate(ExportAccountListDataController.Snapshot)

    var snapshot: ExportAccountListDataController.Snapshot? {
        switch self {
        case .didUpdate(let snapshot): return snapshot
        }
    }
}

enum ExportAccountListAccountHeaderItemState {
    case selectAll
    case unselectAll
    case partialSelection
}
