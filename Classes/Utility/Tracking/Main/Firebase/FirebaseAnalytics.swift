//
//  FirebaseAnalytics.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Firebase

class FirebaseAnalytics: NSObject {
    
    func initialize() {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
    }
}

extension FirebaseAnalytics: AnalyticsTracker {
    func track<Screen: AnalyticsScreen>(_ screen: Screen) {
        if let name = screen.name,
           isTrackable {
            Analytics.logEvent(name.rawValue, parameters: screen.params?.transformToAnalyticsFormat())
        }
    }
    
    func log<Event: AnalyticsEvent>(_ event: Event) {
        if !isTrackable {
            return
        }
        
        Analytics.logEvent(event.key.rawValue, parameters: event.params?.transformToAnalyticsFormat())
    }
    
    func record<Log: AnalyticsLog>(_ log: Log) {
        let error = NSError(domain: log.name.rawValue, code: log.id, userInfo: log.params.transformToAnalyticsFormat())
        Crashlytics.crashlytics().record(error: error)
    }
}
