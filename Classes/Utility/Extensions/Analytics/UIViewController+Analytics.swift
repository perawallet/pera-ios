//
//  UIViewController+Analytics.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

extension UIViewController {
    func track<Screen: AnalyticsScreen>(_ screen: Screen) {
        UIApplication.shared.firebaseAnalytics?.track(screen)
    }
    
    func log<Event: AnalyticsEvent>(_ event: Event) {
        UIApplication.shared.firebaseAnalytics?.log(event)
    }
    
    func record<Log: AnalyticsLog>(_ log: Log) {
        UIApplication.shared.firebaseAnalytics?.record(log)
    }
}
