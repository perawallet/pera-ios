// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   Analytics.swift

import Foundation
import MacaroonVendors

final class Analytics: MacaroonVendors.Analytics {
    let platforms: [AnalyticsPlatform]

    init(platforms: [AnalyticsPlatform]) {
        self.platforms = platforms
    }
}

/// <mark>: API
extension Analytics {
    func initialize() {
        for case let platform as ALGAnalyticsPlatform in platforms {
            platform.initialize()
        }
    }

    func log<T>(_ event: T) where T : AnalyticsTrackableEvent {
        for case let platform as ALGAnalyticsPlatform in platforms {
            if !platform.canTrack(event) {
                return
            }

            platform.log(event)
        }
    }
}
