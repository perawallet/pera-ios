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

//   AssetDetailV2Error.swift

import Foundation
import MacaroonVendors

public struct AssetDetailV2Error: ALGAnalyticsLog {
    public let name: ALGAnalyticsLogName
    public let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        errorDescription: String
    ) {
        name = .assetDetailV2Error
        metadata = [.errorCause: errorDescription]
    }
}

extension ALGAnalyticsLog where Self == AssetDetailV2Error {
    public static func assetDetailV2Error(errorDescription: String) -> Self {
        AssetDetailV2Error(errorDescription: errorDescription)
    }
}
