//
//  ReceiveShareEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveShareEvent: AnalyticsEvent {
    let address: String
    
    let key: AnalyticsEventKey = .showQRShare
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
