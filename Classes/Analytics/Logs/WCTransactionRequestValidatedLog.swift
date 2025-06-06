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

//   WCTransactionRequestValidatedLog.swift

import Foundation

struct WCTransactionRequestValidatedLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        transactionRequest: WalletConnectRequest
    ) {
        self.name = .walletConnectTransactionRequestValidated
        self.metadata = [
            .wcVersion: WalletConnectProtocolID.v1.rawValue,
            .wcRequestID: transactionRequest.id.unwrap(or: ""),
            .wcRequestURL: Self.regulate(transactionRequest.url.absoluteString)
        ]
    }

    fileprivate init(
        transactionRequest: WalletConnectV2Request
    ) {
        self.name = .walletConnectTransactionRequestValidated
        self.metadata = [
            .wcVersion: WalletConnectProtocolID.v2.rawValue,
            .wcSessionTopic: transactionRequest.topic,
            .wcRequestID: transactionRequest.id.string
        ]
    }
}

extension ALGAnalyticsLog where Self == WCTransactionRequestValidatedLog {
    static func wcTransactionRequestValidated(
        transactionRequest: WalletConnectRequest
    ) -> Self {
        return WCTransactionRequestValidatedLog(
            transactionRequest: transactionRequest
        )
    }

    static func wcTransactionRequestValidated(
        transactionRequest: WalletConnectV2Request
    ) -> Self {
        return WCTransactionRequestValidatedLog(
            transactionRequest: transactionRequest
        )
    }
}
