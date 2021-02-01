//
//  AnalyticsTracker.swift

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
