//
//  ReceiveCopyEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveCopyEvent: AnalyticsEvent {
    let address: String

    let key: AnalyticsEventKey = .showQRCopy
    
    var params: AnalyticsParameters? {
        return [.address: address]
    }
}
