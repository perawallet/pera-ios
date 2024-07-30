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

//   IncomingASAAccountsDataController.swift

import Foundation
import UIKit

protocol IncomingASAAccountsDataController: AnyObject {
    var eventHandler: ((IncomingASAAccountsDataControllerEvent) -> Void)? { get set }
    var incomingASAsRequestList: IncomingASAsRequestList? { get }

    func load()
}

enum IncomingASAAccountsSection:
    Int,
    Hashable {
    case accounts
    case empty
}

enum IncomingASAAccountsItem: Hashable {
    case account(IncomingASAAccountCellViewModel)
    case empty
}

struct IncomingASAAccountListItem: Hashable {
    let address: String?
    let inboxAddress: String?
    let requestCount: Int?

    init(address: String?, inboxAddress: String?, requestCount: Int?) {
        self.address = address
        self.inboxAddress = inboxAddress
        self.requestCount = requestCount
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
        hasher.combine(inboxAddress)
        hasher.combine(requestCount)
    }

    static func == (
        lhs: IncomingASAAccountListItem,
        rhs: IncomingASAAccountListItem
    ) -> Bool {
        return
            lhs.address == rhs.address &&
            lhs.inboxAddress == rhs.inboxAddress &&
            lhs.requestCount == rhs.requestCount
    }
}

enum IncomingASAAccountsDataControllerEvent {
    case didUpdate(IncomingASAAccountsUpdates)
}

struct IncomingASAAccountsUpdates {
    let snapshot: Snapshot
    let operation: Operation
}

extension IncomingASAAccountsUpdates {
    enum Operation {
        /// Reload by the last query
        case refresh
    }
}

extension IncomingASAAccountsUpdates {
    typealias Snapshot = NSDiffableDataSourceSnapshot<IncomingASAAccountsSection, IncomingASAAccountsItem>
    typealias Completion = () -> Void
}
