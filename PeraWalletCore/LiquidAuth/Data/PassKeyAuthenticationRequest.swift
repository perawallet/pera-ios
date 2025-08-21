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

import Foundation

<<<<<<<< HEAD:PeraWalletCore/LiquidAuth/Data/PassKeyAuthenticationRequest.swift
public struct PassKeyAuthenticationRequest {
    public let origin: String
    public let username: String
    
    public init(origin: String, username: String) {
        self.origin = origin
        self.username = username
========
public struct RekeyTransactionDraft: TransactionDraft {
    public var from: Account
    public let rekeyedAccount: String
    public var transactionParams: TransactionParams
    
    public init(from: Account, rekeyedAccount: String, transactionParams: TransactionParams) {
        self.from = from
        self.rekeyedAccount = rekeyedAccount
        self.transactionParams = transactionParams
>>>>>>>> main:PeraWalletCore/API/Drafts/SDK/RekeyTransactionDraft.swift
    }
}

