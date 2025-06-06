// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AccountDescendingTitleAlgorithm.swift

import Foundation

struct AccountDescendingTitleAlgorithm: AccountSortingAlgorithm {
    let id: String
    let name: String
    let isCustom: Bool

    init() {
        self.id = "cache.value.accountDescendingTitleAlgorithm"
        self.name = String(localized: "title-alphabetically-z-to-a")
        self.isCustom = false
    }
}

extension AccountDescendingTitleAlgorithm {
    func getFormula(
        account: AccountHandle,
        otherAccount: AccountHandle
    ) -> Bool {
        let accountTitle = account.value.name ?? account.value.address
        let otherAccountTitle = otherAccount.value.name ?? account.value.address
        let result = accountTitle.localizedCaseInsensitiveCompare(otherAccountTitle)
        return result == .orderedDescending
    }
}
