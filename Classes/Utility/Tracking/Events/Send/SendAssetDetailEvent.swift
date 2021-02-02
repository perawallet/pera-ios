//
//  SendAssetDetailEvent.swift

import Foundation

struct SendAssetDetailEvent: AnalyticsEvent {
    let address: String
    
    let key: AnalyticsEventKey = .detailSend
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
