//
//  ChangeAssetDetailEvent.swift

import Foundation

struct ChangeAssetDetailEvent: AnalyticsEvent {
    let assetId: Int64?
    
    let key: AnalyticsEventKey = .assetDetailChange
    
    var params: AnalyticsParameters? {
        if let assetId = assetId {
            return [.assetId: String(assetId)]
        }
        
        return [.assetId: "algos"]
    }
}
