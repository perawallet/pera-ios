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

//   WalletConnectRejectSessionConnectionParams.swift

import Foundation

public protocol WalletConnectRejectSessionConnectionParams {
    var proposalId: String? { get }
    var reason: WalletConnectV2SessionRejectionReason? { get }
}

public struct WalletConnectV1RejectSessionConnectionParams: WalletConnectRejectSessionConnectionParams {
    public let proposalId: String?
    public let reason: WalletConnectV2SessionRejectionReason?
    
    public init(proposalId: String? = nil, reason: WalletConnectV2SessionRejectionReason? = nil) {
        self.proposalId = proposalId
        self.reason = reason
    }
}

public struct WalletConnectV2RejectSessionConnectionParams: WalletConnectRejectSessionConnectionParams {
    public var proposalId: String?
    public var reason: WalletConnectV2SessionRejectionReason?
    
    public init(proposalId: String? = nil, reason: WalletConnectV2SessionRejectionReason? = nil) {
        self.proposalId = proposalId
        self.reason = reason
    }
}
