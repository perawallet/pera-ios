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

//   WalletConnectRejectTransactionRequestParams.swift

import Foundation

public protocol WalletConnectRejectTransactionRequestParams: WalletConnectParams {
    var v1Request: WalletConnectRequest? { get }
    var error: WCTransactionErrorResponse? { get }
    var v2Request: WalletConnectV2Request? { get }
}

public struct WalletConnectV1RejectTransactionRequestParams: WalletConnectRejectTransactionRequestParams {
    public var v1Request: WalletConnectRequest?
    public var error: WCTransactionErrorResponse?
    public let v2Request: WalletConnectV2Request? = nil
    public let currentProtocolID: WalletConnectProtocolID = .v1
    
    public init(v1Request: WalletConnectRequest? = nil, error: WCTransactionErrorResponse? = nil) {
        self.v1Request = v1Request
        self.error = error
    }
}

public struct WalletConnectV2RejectTransactionRequestParams: WalletConnectRejectTransactionRequestParams {
    public let v1Request: WalletConnectRequest? = nil
    public var error: WCTransactionErrorResponse?
    public var v2Request: WalletConnectV2Request?
    public let currentProtocolID: WalletConnectProtocolID = .v2
    
    public init(v2Request: WalletConnectV2Request? = nil, error: WCTransactionErrorResponse? = nil) {
        self.v2Request = v2Request
        self.error = error
    }
}
