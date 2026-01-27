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

//   ProposeSignRequest.swift

enum ProposedSignType: String, Codable {
    case sync
    case async
}

struct ProposeSignRequest {
    let jointAccountAddress: String
    let proposerAddress: String
    let type: ProposedSignType
    let rawTransactionLists: [[String]]
    let transactionSignatureLists: [[String]]?
}

extension ProposeSignRequest: BodyRequestable {
    
    typealias ResponseType = ProposeSignResponse
    
    var path: String { "/joint-accounts/sign-requests/" }
    var method: RequestMethod { .post }
    var body: any Encodable { self }
}

struct ProposeSignResponse: Decodable {
    let id: String
    let jointAccount: MultiSigAccountObject
    let type: ProposedSignType
    let transactionLists: [SignRequestTransactionObject]
    let expectedExpireDatetime: String
    let status: JointAccountTransactionStatus
}
