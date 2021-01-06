//
//  ReceiveAssetDetailEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveAssetDetailEvent: AnalyticsEvent {
    let address: String
    
    let key: AnalyticsEventKey = .detailReceive
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
