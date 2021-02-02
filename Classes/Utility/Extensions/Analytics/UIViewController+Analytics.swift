//
//  UIViewController+Analytics.swift

import UIKit

extension UIViewController {
    func track(_ screen: AnalyticsScreen) {
        UIApplication.shared.firebaseAnalytics?.track(screen)
    }
    
    func log(_ event: AnalyticsEvent) {
        UIApplication.shared.firebaseAnalytics?.log(event)
    }
    
    func record(_ log: AnalyticsLog) {
        UIApplication.shared.firebaseAnalytics?.record(log)
    }
}
