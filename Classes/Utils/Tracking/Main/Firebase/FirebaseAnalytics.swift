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

//
//  FirebaseAnalytics.swift

import Firebase
import FirebaseAnalytics
import MacaroonVendors

final class FirebaseAnalytics: ALGAnalyticsPlatform {
    func initialize() {
        FirebaseApp.configure()
        Firebase.Analytics.setAnalyticsCollectionEnabled(true)
    }

    func identify<T>(user: T, first: Bool) where T : AnalyticsTrackableUser {
        fatalError("ID cannot applied right now")
    }

    func canTrack<T>(_ screen: T) -> Bool where T : AnalyticsTrackableScreen {
        return isTrackable
    }

    func track<T>(_ screen: T) where T : AnalyticsTrackableScreen {
        if isTrackable {
            Firebase.Analytics.logEvent(screen.name, parameters: nil)
        }
    }

    func canTrack<T>(_ event: T) -> Bool where T : AnalyticsTrackableEvent {
        return isTrackable
    }

    func track<T>(_ event: T) where T : AnalyticsTrackableEvent {
        if !canTrack(event) {
            return
        }

        Firebase.Analytics.logEvent(
            event.type.description,
            parameters: event.transformToAnalyticsFormat()
        )
    }

    func reset() {
        Firebase.Analytics.resetAnalyticsData()
    }

    func log<T>(_ event: T) where T : AnalyticsTrackableEvent {

    }
}

extension FirebaseAnalytics {
    func record(_ log: AnalyticsLog) {
        let error = NSError(domain: log.name.rawValue, code: log.id, userInfo: log.params.transformToAnalyticsFormat())
        Crashlytics.crashlytics().record(error: error)
    }
}
