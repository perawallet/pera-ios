// Copyright 2025 Pera Wallet, LDA

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

struct PeraAccount {
    
    enum AccountType {
        case algo25
        case universalWallet
        case watch
        case invalid
    }

    enum AuthorizedAccountType {
        case wallet
        case ledger
        case invalid
    }
    
    let address: String
    let type: AccountType
    let authType: AuthorizedAccountType?
}

extension PeraAccount {
    var isBackupable: Bool { type != .invalid && authType != .invalid }
}
