//
//  ReceiveCopyEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveCopyEvent: TrackableEvent {
    let eventKey = "tap_receive_copy"
    let address: String
    
    var parameters: [String: Any]? {
        return [
            "address": address
        ]
    }
}
