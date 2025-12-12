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

//   ALGAnalytics.swift

import Foundation
import MacaroonVendors

public protocol ALGAnalytics: Analytics {
    func record(
        _ log: ALGAnalyticsLog
    )
    func track(
        _ log: any AnalyticsScreen
    )
}

extension ALGAnalytics {
    public func record(
        _ log: ALGAnalyticsLog
    ) {
        providers
            .compactMap { $0 as? ALGAnalyticsProvider }
            .filter { $0.canRecord(log) }
            .forEach { $0.record(log) }
    }
    public func track(
        _ log: any AnalyticsScreen
    ) {
        providers
            .compactMap { $0 as? ALGAnalyticsProvider }
            .filter { $0.canTrack(log) }
            .forEach { $0.track(log) }
    }
    
    public func track(
        _ event: String,
        payload: [String: String]?
    ) {
        providers
            .compactMap { $0 as? ALGAnalyticsProvider }
            .filter { $0.canTrack(event) }
            .forEach { $0.track(event, payload: payload) }
    }
}
