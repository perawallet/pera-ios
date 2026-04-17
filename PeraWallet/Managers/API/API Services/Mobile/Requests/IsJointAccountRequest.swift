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

//   IsJointAccountRequest.swift

struct IsJointAccountRequest {
    /// Addresses to check. The server returns one item per input address indicating
    /// whether it is already registered as a shared (joint) account.
    let accountAddresses: [String]
}

extension IsJointAccountRequest: BodyRequestable {

    typealias ResponseType = [IsJointAccountResponse]

    var path: String { "/joint-accounts/is-joint-account/" }
    var method: RequestMethod { .post }
    var body: any Encodable { self }
}
