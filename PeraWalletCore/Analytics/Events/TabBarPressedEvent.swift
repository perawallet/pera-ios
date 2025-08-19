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

//   TabBarPressedEvent.swift

import Foundation
import MacaroonVendors

public struct TabBarPressedEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension TabBarPressedEvent {
    public enum `Type` {
        case tapHome
        case tapDiscover
        case tapQuickConnect
        case tapNFTs
        case tapSettings
        case tapMenu
        case tapSwap
        case tapStake

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .tapHome:
                return .tapBarPressedHomeEvent
            case .tapDiscover:
                return .tapBarPressedDiscoverEvent
            case .tapQuickConnect:
                return .tapBarPressedQuickConnectEvent
            case .tapNFTs:
                return .tapBarPressedNFTsEvent
            case .tapSettings:
                return .tapBarPressedSettingsEvent
            case .tapMenu:
                return .tapBarPressedMenuEvent
            case .tapSwap:
                return .tapBarPressedSwapEvent
            case .tapStake:
                return .tapBarPressedStakeEvent
            }
        }
    }
}

extension AnalyticsEvent where Self == TabBarPressedEvent {
    public static func tabBarPressed(
        type: TabBarPressedEvent.`Type`
    ) -> Self {
        return TabBarPressedEvent(type: type)
    }
}
