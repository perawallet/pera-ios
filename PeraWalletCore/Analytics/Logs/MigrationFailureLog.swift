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

/// <note>: MigrationFailureLog description below
/// When a migration fails we want to capture as much data about the failure as possible to debug
public struct MigrationFailureLog: ALGAnalyticsLog {
    public let name: ALGAnalyticsLogName
    public let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        message: String,
        cause: Error?
    ) {
        self.name = .migrationFailure
        self.metadata = [
            .errorDetails: "\(message)",
            .errorCause: "\(cause ?? "No cause")"
        ]
    }
}

extension ALGAnalyticsLog where Self == MigrationFailureLog {
    public static func migrationFailure(
        message: String,
        cause: Error?
    ) -> Self {
        return MigrationFailureLog(
            message: message,
            cause: cause
        )
    }
}
