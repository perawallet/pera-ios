//
//  ReceiveShareCompleteEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveShareCompleteEvent: AnalyticsEvent {
    let address: String
    
    let key: AnalyticsEventKey = .showQRShareComplete
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
