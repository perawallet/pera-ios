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

//   SwapV2SettingsEvent.swift

import Foundation
import MacaroonVendors

public struct SwapV2SettingsEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type,
        value: String?
    ) {
        self.name = type.rawValue
        
        if let value {
            self.metadata = [.routerName: value]
        } else {
            self.metadata = [:]
        }
    }
}

extension SwapV2SettingsEvent {
    public enum `Type` {
        case settingsClose
        case settingsApply
        case settingsPercentageSelected
        case settingsSlippageSelected
        case settingsLocalCurrencyOn
        case settingsLocalCurrencyOff

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .settingsClose:
                return .swapSettingsClose
            case .settingsApply:
                return .swapSettingsApply
            case .settingsPercentageSelected:
                return .swapSettingsPercentage
            case .settingsSlippageSelected:
                return .swapSettingsSlippage
            case .settingsLocalCurrencyOn:
                return .swapSettingsLocalCurrencyOn
            case .settingsLocalCurrencyOff:
                return .swapSettingsLocalCurrencyOff
            }
        }
    }
}

extension AnalyticsEvent where Self == SwapV2SettingsEvent {
    public static func swapV2SettingsEvent(
        type: SwapV2SettingsEvent.`Type`,
        value: String?
    ) -> Self {
        return SwapV2SettingsEvent(type: type, value: value)
    }
}
