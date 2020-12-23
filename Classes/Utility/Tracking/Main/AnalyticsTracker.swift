//
//  AnalyticsTracker.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation
import UIKit

protocol AnalyticsTracker {
    func track(_ screen: AnalyticsScreen)
    func log(_ event: AnalyticsEvent)
    func record(_ log: AnalyticsLog)
}

extension AnalyticsTracker {
    /// Screen and event trackings should not be completed on TestNet.
    var isTrackable: Bool {
        return !(UIApplication.shared.appConfiguration?.api.isTestNet ?? false)
    }
}
