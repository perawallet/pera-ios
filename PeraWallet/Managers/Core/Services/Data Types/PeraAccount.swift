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

//   PeraAccount.swift

struct PeraAccount: Hashable {
    
    enum AccountType: CaseIterable {
        case algo25
        case universalWallet
        case watch
        case ledger
        case joint
        case invalid
    }

    enum AuthorizedAccountType {
        case algo25
        case universalWallet
        case ledger
        case invalid
    }
    
    struct Titles: Hashable {
        let primary: String
        let secondary: String?
    }
    
    let address: String
    let type: AccountType
    let authType: AuthorizedAccountType?
    let amount: Double
    let titles: Titles
    let sortingIndex: Int
}

extension PeraAccount {
    var isValid: Bool { type != .invalid && authType != .invalid }
}

extension PeraAccount.AccountType {
    var isStandardAccount: Bool { self == .algo25 || self == .universalWallet }
}

extension PeraAccount.AccountType {
    
    var name: String? {
        switch self {
        case .algo25, .universalWallet:
            nil
        case .watch:
            String(localized: "common-account-type-name-watch")
        case .ledger:
            String(localized: "common-account-type-name-ledger")
        case .joint:
            String(localized: "common-account-type-name-joint")
        case .invalid:
            String(localized: "common-account-type-name-no-auth")
        }
    }
}

extension PeraAccount.AuthorizedAccountType {
    
    var name: String {
        switch self {
        case .algo25, .universalWallet, .ledger:
            String(localized: "common-account-type-name-rekeyed")
        case .invalid:
            String(localized: "common-account-type-name-no-auth")
        }
    }
}
