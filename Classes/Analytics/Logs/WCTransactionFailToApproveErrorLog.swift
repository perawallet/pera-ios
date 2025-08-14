// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCTransactionFailToApproveErrorLog.swift

import Foundation

struct WCTransactionFailToApproveErrorLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        error: Error
    ) {
        self.name = .walletConnectTransactionApprovalFailedError
        
        self.metadata = [
            .wcVersion: WalletConnectProtocolID.v1.rawValue,
            .wcActionError: error.localizedDescription
        ]
    }
}

extension ALGAnalyticsLog where Self == WCTransactionFailToApproveErrorLog {
    static func wcTransactionFailToApproveErrorLog(
        error: Error
    ) -> Self {
        return WCTransactionFailToApproveErrorLog(error: error)
    }
}
