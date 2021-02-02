//
//  DisplayAssetDetailEvent.swift

import Foundation

struct DisplayAssetDetailEvent: AnalyticsEvent {
    let assetId: Int64?
    
    let key: AnalyticsEventKey = .assetDetail
    
    var params: AnalyticsParameters? {
        if let assetId = assetId {
            return [.assetId: String(assetId)]
        }
        
        return [.assetId: "algos"]
    }
}
