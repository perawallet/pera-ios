//
//  ReceiveShareEvent.swift

import Foundation

struct ReceiveShareEvent: AnalyticsEvent {
    let address: String
    
    let key: AnalyticsEventKey = .showQRShare
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
