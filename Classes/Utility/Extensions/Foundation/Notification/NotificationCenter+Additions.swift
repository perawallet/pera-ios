//
//  NotificationCenter+Additions.swift

import Foundation

extension NotificationCenter {
    
    static func unobserve(_ tracker: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(tracker)
    }
}
