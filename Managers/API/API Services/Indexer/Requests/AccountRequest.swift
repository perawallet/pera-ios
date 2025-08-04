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

//   AccountRequest.swift

struct AccountRequest {
    /// The account public key
    let publicKey: String
}

extension AccountRequest: Requestable {
    
    typealias ResponseType = AccountResponse
    
    var path: String { "/accounts/\(publicKey)" }
    var method: RequestMethod { .get }
}

struct AccountResponse: Decodable {
    /// The account data
    let account: IndexerAccount
}

struct IndexerAccount: Decodable {
    /// The account public key
    let address: String
    /// The address against which signing should be checked. If empty, the address of the current account is used.
    let authAddr: String?
}
