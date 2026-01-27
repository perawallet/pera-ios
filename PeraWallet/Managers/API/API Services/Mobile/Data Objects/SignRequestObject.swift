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

//   SignRequestObject.swift

import Foundation

struct SignRequestObject: Decodable, Equatable {
    
    enum SignType: String, Decodable {
        case sync
        case async
    }
    
    enum Status: String, Decodable {
        case pending
        case ready
        case submitting
        case confirmed
        case failed
        case expired
    }
    
    let id: String
    let jointAccount: MultiSigAccountObject
    let type: SignType
    let transactionLists: [SignRequestTransactionObject]
    let transactionSignatureLists: [[String]]?
    let expectedExpireDatetime: Date
    let status: Status
    let creationDatetime: Date
}

struct SignRequestTransactionObject: Decodable, Equatable {
    let id: Int
    let rawTransactions: [String]
    let firstValidBlock: String
    let lastValidBlock: String
    let responses: [SignRequestTransactionResponseObject]
    let expectedExpireDatetime: Date
}

struct SignRequestTransactionResponseObject: Decodable, Equatable {
    
    enum Response: String, Decodable {
        case signed
        case declined
    }
    
    let address: String
    let response: Response
    let signatures: [[String]]?
    let deviceId: String?
}
