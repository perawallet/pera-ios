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

//   JointAccountSignRequest.swift

struct JointAccountSignRequest {
    
    enum Response: String, Encodable {
        case signed
        case declined
    }
    
    let participantAddress: String
    let signRequestId: String
    let response: Response
    let signatures: [[String]]?
    let deviceId: String?
}

extension JointAccountSignRequest: BodyRequestable {
    
    typealias ResponseType = SignRequestObject
    
    var path: String { "/joint-accounts/sign-requests/\(signRequestId)/responses/\(participantAddress)/" }
    var method: RequestMethod { .post }
    var body: any Encodable { JointAccountSignRequestBody(response: response, signatures: signatures, deviceId: deviceId) }
}

private struct JointAccountSignRequestBody: Encodable {
    let response: JointAccountSignRequest.Response
    let signatures: [[String]]?
    let deviceId: String?
}
