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

//   SwapV2ConfirmEvent.swift

import Foundation
import MacaroonVendors

public struct SwapV2ConfirmEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension SwapV2ConfirmEvent {
    public enum `Type` {
        case confirmSwap
        case confirmSlide

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .confirmSwap:
                return .tapSwapInSwapScreen
            case .confirmSlide:
                return .tapConfirmSwap
            }
        }
    }
}

extension AnalyticsEvent where Self == SwapV2ConfirmEvent {
    public static func swapV2ConfirmEvent(
        type: SwapV2ConfirmEvent.`Type`
    ) -> Self {
        return SwapV2ConfirmEvent(type: type)
    }
}
