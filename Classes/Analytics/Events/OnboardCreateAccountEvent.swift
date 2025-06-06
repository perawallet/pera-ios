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

//   OnboardCreateAccountEvent.swift

import Foundation
import MacaroonVendors

struct OnboardCreateAccountEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension OnboardCreateAccountEvent {
    enum `Type` {
        case new
        case skip
        case watch
        case watchComplete
        case recoverAlgo25
        case recoverOneKey

        var rawValue: ALGAnalyticsEventName {
            switch self {
            case .new:
                return .onboardCreateAccountNew
            case .skip:
                return .onboardCreateAccountSkip
            case .watch:
                return .onboardCreateAccountWatch
            case .watchComplete:
                return .onboardCreateAccountWatchComplete
            case .recoverAlgo25:
                return .onboardCreateAccountRecoverAlgo25
            case .recoverOneKey:
                return .onboardCreateAccountRecoverOneKey
            }
        }
    }
}

extension AnalyticsEvent where Self == OnboardCreateAccountEvent {
    static func onboardCreateAccount(
        type: OnboardCreateAccountEvent.`Type`
    ) -> Self {
        return OnboardCreateAccountEvent(type: type)
    }
}
