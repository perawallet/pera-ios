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

//   MultiSigAccountObject.swift

import Foundation

struct MultiSigAccountObject: Encodable, Decodable, Equatable {
    /// The public address of the multisig account.
    let address: String
    /// The list of participant public addresses involved in the multisig account.
    let participantAddresses: [String]
    /// The minimum number of signatures required to authorize a transaction.
    let threshold: Int
    /// The version of the multisig scheme being used
    let version: Int
    /// Creation date in ISO 8601 format.
    let creationDatetime: Date
}
