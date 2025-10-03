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

//   SwapV2TopPairEvent.swift

import Foundation
import MacaroonVendors

public struct SwapV2TopPairEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type,
        swapPairing: String?
    ) {
        self.name = type.rawValue
        self.metadata = [.swapPairing: swapPairing]
        
    }
}

extension SwapV2TopPairEvent {
    public enum `Type` {
        case selectTopPair

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .selectTopPair:
                return .swapSelectTopPair
            }
        }
    }
}

extension AnalyticsEvent where Self == SwapV2TopPairEvent {
    public static func swapV2TopPairEvent(
        type: SwapV2TopPairEvent.`Type`,
        swapPairing: String?
    ) -> Self {
        return SwapV2TopPairEvent(type: type, swapPairing: swapPairing)
    }
}

