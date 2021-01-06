//
//  SendAssetDetailEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct SendAssetDetailEvent: AnalyticsEvent {
    let address: String
    
    let key: AnalyticsEventKey = .detailSend
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
