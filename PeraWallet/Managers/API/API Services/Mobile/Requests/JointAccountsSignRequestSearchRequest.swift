// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   JointAccountsSignRequestSearchRequest.swift

import Foundation

struct JointAccountsSignRequestSearchRequest {
    let deviceID: String
    let participantAddresses: [String]?
    let jointAccountAddresses: [String]?
    let signRequestID: String?
    let status: SignRequestObject.SignType?
}

extension JointAccountsSignRequestSearchRequest: BodyRequestable {
    
    typealias ResponseType = JointAccountsSignRequestSearchResponse
    
    var path: String { "/joint-accounts/sign-requests/search/" }
    var method: RequestMethod { .post }
    var body: Encodable { self }
}

struct JointAccountsSignRequestSearchResponse: Decodable {
    let results: [JointAccountsSignRequestSearchDataObject]
}

struct JointAccountsSignRequestSearchDataObject: Decodable {
    let id: String?
    let jointAccount: MultiSigAccountObject?
    let type: SignRequestObject.SignType
    let transactionLists: [SignRequestTransactionObject]?
    let expectedExpireDatetime: Date?
    let status: SignRequestObject.Status?
    let creationDatetime: Date?
    let failReasonDisplay: String?
}
