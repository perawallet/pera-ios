//
//  ReceiveCopyEvent.swift

import Foundation

struct ReceiveCopyEvent: AnalyticsEvent {
    let address: String

    let key: AnalyticsEventKey = .showQRCopy
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
