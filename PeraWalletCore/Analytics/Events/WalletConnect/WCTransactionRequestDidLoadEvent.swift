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

//   WCTransactionRequestDidLoadEvent.swift

import Foundation
import MacaroonVendors

public struct WCTransactionRequestDidLoadEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        transactionRequest: WalletConnectRequest
    ) {
        self.name = .wcTransactionRequestDidLoad
        self.metadata = [
            .wcVersion: WalletConnectProtocolID.v1.rawValue,
            .wcRequestID: transactionRequest.id ?? "",
            .wcRequestURL: Self.regulate(transactionRequest.url.absoluteString)
        ]
    }

    fileprivate init(
        transactionRequest: WalletConnectV2Request
    ) {
        self.name = .wcTransactionRequestDidLoad
        self.metadata = [
            .wcVersion: WalletConnectProtocolID.v2.rawValue,
            .wcSessionTopic: transactionRequest.topic,
            .wcRequestID: transactionRequest.id.string
        ]
    }
}

extension AnalyticsEvent where Self == WCTransactionRequestDidLoadEvent {
    public static func wcTransactionRequestDidLoad(
        transactionRequest: WalletConnectRequestDraft
    ) -> Self {
        if let wcV1Request = transactionRequest.wcV1Request {
            return .wcTransactionRequestDidLoad(transactionRequest: wcV1Request)
        }

        return .wcTransactionRequestDidLoad(transactionRequest: transactionRequest.wcV2Request!)
    }

    public static func wcTransactionRequestDidLoad(
        transactionRequest: WalletConnectRequest
    ) -> Self {
        return WCTransactionRequestDidLoadEvent(
            transactionRequest: transactionRequest
        )
    }

    public static func wcTransactionRequestDidLoad(
        transactionRequest: WalletConnectV2Request
    ) -> Self {
        return WCTransactionRequestDidLoadEvent(
            transactionRequest: transactionRequest
        )
    }
}
