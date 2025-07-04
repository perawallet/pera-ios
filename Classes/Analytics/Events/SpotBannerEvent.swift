// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SpotBannerEvent.swift

import Foundation
import MacaroonVendors

struct SpotBannerEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type,
        name: String
    ) {
        self.name = type.rawValue
        self.metadata = [.bannerName: name]
    }
}

extension SpotBannerEvent {
    enum `Type` {
        case tapClose
        case tapBanner

        var rawValue: ALGAnalyticsEventName {
            switch self {
            case .tapClose:
                return .tapSpotBannerCloseButton
            case .tapBanner:
                return .tapSpotBanner
            }
        }
    }
}

extension AnalyticsEvent where Self == SpotBannerEvent {
    static func spotBannerPressed(
        type: SpotBannerEvent.`Type`,
        name: String
    ) -> Self {
        return SpotBannerEvent(type: type, name: name)
    }
}
