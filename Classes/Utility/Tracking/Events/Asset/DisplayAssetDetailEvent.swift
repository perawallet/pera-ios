//
//  DisplayAssetDetailEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

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
