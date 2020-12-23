//
//  UIViewController+Analytics.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

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
