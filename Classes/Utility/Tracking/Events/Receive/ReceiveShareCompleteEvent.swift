//
//  ReceiveShareCompleteEvent.swift

import Foundation

struct ReceiveShareCompleteEvent: AnalyticsEvent {
    let address: String
    
    let key: AnalyticsEventKey = .showQRShareComplete
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
