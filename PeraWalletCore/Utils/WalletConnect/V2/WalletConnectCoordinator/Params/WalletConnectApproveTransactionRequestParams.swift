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

//   WalletConnectApproveTransactionRequestParams.swift

import Foundation

public protocol WalletConnectApproveTransactionRequestParams: WalletConnectParams {
    var v1Request: WalletConnectRequest? { get }
    var signature: [Data?]? { get }
    var v2Request: WalletConnectV2Request? { get }
    var response: WalletConnectV2CodableResult? { get }
}

public struct WalletConnectV1ApproveTransactionRequestParams: WalletConnectApproveTransactionRequestParams {
    public var v1Request: WalletConnectRequest?
    public var signature: [Data?]?
    public let v2Request: WalletConnectV2Request? = nil
    public let response: WalletConnectV2CodableResult? = nil
    public let currentProtocolID: WalletConnectProtocolID = .v1
    
    public init(v1Request: WalletConnectRequest? = nil, signature: [Data?]? = nil) {
        self.v1Request = v1Request
        self.signature = signature
    }
}

public struct WalletConnectV2ApproveTransactionRequestParams: WalletConnectApproveTransactionRequestParams {
    public let v1Request: WalletConnectRequest? = nil
    public let signature: [Data?]? = nil
    public var v2Request: WalletConnectV2Request?
    public var response: WalletConnectV2CodableResult?
    public let currentProtocolID: WalletConnectProtocolID = .v2
    
    public init(v2Request: WalletConnectV2Request? = nil, response: WalletConnectV2CodableResult? = nil) {
        self.v2Request = v2Request
        self.response = response
    }
}
