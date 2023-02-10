// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCTransactionRequestReceivedLog.swift

import Foundation

struct WCTransactionRequestReceivedLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        transactionRequest: WalletConnectRequest
    ) {
        self.name = .walletConnectTransactionRequestReceived
        self.metadata = [
            .wcRequestID: transactionRequest.id.unwrap(or: ""),
            .wcRequestURL: Self.regulate(transactionRequest.url.absoluteString)
        ]
    }
}

extension ALGAnalyticsLog where Self == WCTransactionRequestReceivedLog {
    static func wcTransactionRequestReceived(
        transactionRequest: WalletConnectRequest
    ) -> Self {
        return WCTransactionRequestReceivedLog(
            transactionRequest: transactionRequest
        )
    }
}
