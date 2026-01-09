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

//   InboxCreateRequest.swift

struct InboxCreateRequest {
    let deviceID: String
    let addresses: [String]
}

struct InboxCreateResponse: Decodable {
    let jointAccountImportRequests: [MultiSigAccountObject]
    let jointAccountSignRequests: [SignRequestObject]
    let asaInboxes: [ASAInboxMeta]
}

extension InboxCreateRequest: BodyRequestable {
    
    typealias ResponseType = InboxCreateResponse
    
    var path: String { "/inbox/\(deviceID)/"}
    var method: RequestMethod { .post }
    var body: any Encodable { ["addresses": addresses] }
}
