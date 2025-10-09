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

//   SwapV2HistoryEvent.swift

import Foundation
import MacaroonVendors

public struct SwapV2HistoryEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type,
        swapPairing: String?
    ) {
        self.name = type.rawValue
        
        if let swapPairing {
            self.metadata = [.swapPairing: swapPairing]
        } else {
            self.metadata = [:]
        }
        
    }
}

extension SwapV2HistoryEvent {
    public enum `Type` {
        case historySeeAll
        case selectHistory
        case selectHistoryInSeeAll

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .historySeeAll:
                return .swapHistorySeeAll
            case .selectHistory:
                return .swapSelectHistory
            case .selectHistoryInSeeAll:
                return .swapSelectHistoryInSeeAll
            }
        }
    }
}

extension AnalyticsEvent where Self == SwapV2HistoryEvent {
    public static func swapV2HistoryEvent(
        type: SwapV2HistoryEvent.`Type`,
        swapPairing: String?
    ) -> Self {
        return SwapV2HistoryEvent(type: type, swapPairing: swapPairing)
    }
}
