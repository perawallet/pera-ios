//
//  ReceiveAssetDetailEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveAssetDetailEvent: TrackableEvent {
    let eventKey = "tap_asset_detail_receive"
    let address: String
    
    var parameters: [String: Any]? {
        return [
            "address": address
        ]
    }
}
