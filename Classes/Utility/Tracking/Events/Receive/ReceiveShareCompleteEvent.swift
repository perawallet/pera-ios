//
//  ReceiveShareCompleteEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveShareCompleteEvent: TrackableEvent {
    var eventKey = "tap_receive_share_complete"
    let address: String
    
    var parameters: [String: Any]? {
        return [
            "address": address
        ]
    }
}
