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

//   AccountSorting.swift

import Foundation

protocol AccountSorting {
    var id: String { get }
    var title: String { get }

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle]
}

struct AccountSortingWithAlphabetically: AccountSorting {
    var id: String {
        switch order {
        case .ascending:
            return "alphabeticalyAscending"
        case .descending:
            return "alphabeticalyDescending"
        }
    }

    var title: String {
        switch order {
        case .ascending:
            return"title-alphabetically-a-to-z".localized
        case .descending:
            return "title-alphabetically-z-to-a".localized
        }
    }

    private let order: SortOrder

    init(
        _ order: SortOrder
    ) {
        self.order = order
    }

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle] {
        return accounts.sorted(
            by: \.value.name,
            using:  order == .descending ? (>) : (<)
        )
    }
}

struct AccountSortingWithValue: AccountSorting {
    var id: String {
        switch order {
        case .ascending:
            return "valueAscending"
        case .descending:
            return "valueDescending"
        }
    }

    var title: String {
        switch order {
        case .ascending:
            return "title-lowest-value-to-highest".localized
        case .descending:
            return "title-highest-value-to-lowest".localized
        }
    }

    private let order: SortOrder

    init(
        _ order: SortOrder
    ) {
        self.order = order
    }

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle] {
        return accounts.sorted(
            by: \.value.amount,
            using: order == .descending ? (>) : (<)
        )
    }
}

struct AccountSortingWithManually: AccountSorting {
    var id: String = "manually"
    var title: String = "title-manually".localized

    func sort(
        _ accounts: [AccountHandle]
    ) -> [AccountHandle] {
        return accounts
    }
}

enum SortOrder {
    case ascending
    case descending
}
