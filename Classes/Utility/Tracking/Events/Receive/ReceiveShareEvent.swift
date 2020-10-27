//
//  ReceiveShareEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveShareEvent: TrackableEvent {
    let eventKey = "tap_receive_share"
    let address: String
    
    var parameters: [String: Any]? {
        return [
            "address": address
        ]
    }
}
