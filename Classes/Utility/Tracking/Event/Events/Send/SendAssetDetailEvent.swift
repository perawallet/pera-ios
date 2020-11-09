//
//  SendAssetDetailEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct SendAssetDetailEvent: TrackableEvent {
    let eventKey = "tap_asset_detail_send"
    let address: String
    
    var parameters: [String: Any]? {
        return [
            "address": address
        ]
    }
}
