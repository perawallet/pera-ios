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

//  LedgerTransactionErrorLog.swift

import Foundation
import MacaroonVendors

/// <note>: PersitentContainerCreationError description below
/// When a migration fails we want to capture as much data about the failure as possible to debug
public struct PersitentContainerCreationError: ALGAnalyticsLog {
    public let name: ALGAnalyticsLogName
    public let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        appGroup: String,
        errorDetails: String
    ) {
        self.name = .persistentContainerCreationError
        self.metadata = [
            .errorDetails: "\(errorDetails)",
            .appGroupName: appGroup
        ]
    }
}

extension ALGAnalyticsLog where Self == PersitentContainerCreationError {
    public static func persistentContainerCreationError(
        appGroup: String,
        errorDetails: String
    ) -> Self {
        return PersitentContainerCreationError(
            appGroup: appGroup,
            errorDetails: errorDetails
        )
    }
}
