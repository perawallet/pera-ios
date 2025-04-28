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

//   SwapSelectTokenEvent.swift

import Foundation
import MacaroonVendors

struct SwapSelectTokenEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type,
        assetID: AssetID
    ) {
        self.name = type.rawValue

        self.metadata = [
            .assetID: String(assetID)
        ]
    }
}

extension SwapSelectTokenEvent {
    enum `Type` {
        case from
        case to

        var rawValue: ALGAnalyticsEventName {
            switch self {
            case .from:
                return .swapSelectFromToken
            case .to:
                return .swapSelectToToken
            }
        }
    }
}

extension AnalyticsEvent where Self == SwapSelectTokenEvent {
    static func swapSelectToken(
        type: SwapSelectTokenEvent.`Type`,
        assetID: AssetID
    ) -> Self {
        return SwapSelectTokenEvent(type: type, assetID: assetID)
    }
}
