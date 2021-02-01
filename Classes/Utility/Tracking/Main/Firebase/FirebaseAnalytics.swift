//
//  FirebaseAnalytics.swift

import Firebase

class FirebaseAnalytics: NSObject {
    
    func initialize() {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
    }
}

extension FirebaseAnalytics: AnalyticsTracker {
    func track(_ screen: AnalyticsScreen) {
        if let name = screen.name,
           isTrackable {
            Analytics.logEvent(name.rawValue, parameters: screen.params?.transformToAnalyticsFormat())
        }
    }
    
    func log(_ event: AnalyticsEvent) {
        if !isTrackable {
            return
        }
        
        Analytics.logEvent(event.key.rawValue, parameters: event.params?.transformToAnalyticsFormat())
    }
    
    func record(_ log: AnalyticsLog) {
        let error = NSError(domain: log.name.rawValue, code: log.id, userInfo: log.params.transformToAnalyticsFormat())
        Crashlytics.crashlytics().record(error: error)
    }
}
