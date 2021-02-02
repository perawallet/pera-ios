//
//  ReceiveAssetDetailEvent.swift

import Foundation

struct ReceiveAssetDetailEvent: AnalyticsEvent {
    let address: String
    
    let key: AnalyticsEventKey = .detailReceive
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
