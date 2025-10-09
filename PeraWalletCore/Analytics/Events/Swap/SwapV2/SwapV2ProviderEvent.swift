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

//   SwapV2ProviderEvent.swift

import Foundation
import MacaroonVendors

public struct SwapV2ProviderEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type,
        routerName: String?
    ) {
        self.name = type.rawValue
        
        if let routerName {
            self.metadata = [.routerName: routerName]
        } else {
            self.metadata = [:]
        }
    }
}

extension SwapV2ProviderEvent {
    public enum `Type` {
        case selectProviderOpen
        case selectProviderClose
        case selectProviderApply
        case selectProviderRouter

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .selectProviderOpen:
                return .swapSelectProviderOpen
            case .selectProviderClose:
                return .swapSelectProviderClose
            case .selectProviderApply:
                return .swapSelectProviderApply
            case .selectProviderRouter:
                return .swapSelectProviderRouter
            }
        }
    }
}

extension AnalyticsEvent where Self == SwapV2ProviderEvent {
    public static func swapV2ProviderEvent(
        type: SwapV2ProviderEvent.`Type`,
        routerName: String?
    ) -> Self {
        return SwapV2ProviderEvent(type: type, routerName: routerName)
    }
}
