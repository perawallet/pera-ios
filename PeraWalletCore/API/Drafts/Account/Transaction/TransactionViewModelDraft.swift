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

//
//  TransactionViewModelDraft.swift

import Foundation

public struct TransactionViewModelDraft {
    public let account: Account
    public let asset: AssetDecoration?
    public let transaction: TransactionItem
    public var contact: Contact?
    public let localAccounts: [Account]
    public let localAssets: AssetDetailCollection?
    
    public init(account: Account, asset: AssetDecoration?, transaction: TransactionItem, contact: Contact? = nil, localAccounts: [Account], localAssets: AssetDetailCollection?) {
        self.account = account
        self.asset = asset
        self.transaction = transaction
        self.contact = contact
        self.localAccounts = localAccounts
        self.localAssets = localAssets
    }
}
