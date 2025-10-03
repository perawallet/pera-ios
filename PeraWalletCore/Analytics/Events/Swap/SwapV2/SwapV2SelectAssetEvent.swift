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

//   SwapV2SelectAssetEvent.swift

import Foundation
import MacaroonVendors

public struct SwapV2SelectAssetEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type,
        assetName: String
    ) {
        self.name = type.rawValue
        self.metadata = [.assetName: assetName]
    }
}

extension SwapV2SelectAssetEvent {
    public enum `Type` {
        case selectTopAsset
        case selectBottomAsset

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .selectTopAsset:
                return .swapSelectTopAsset
            case .selectBottomAsset:
                return .swapSelectBottomAsset
            }
        }
    }
}

extension AnalyticsEvent where Self == SwapV2SelectAssetEvent {
    public static func swapV2SelectAssetEvent(
        type: SwapV2SelectAssetEvent.`Type`,
        assetName: String
    ) -> Self {
        return SwapV2SelectAssetEvent(type: type, assetName: assetName)
    }
}
