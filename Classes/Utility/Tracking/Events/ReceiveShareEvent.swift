//
//  ReceiveShareEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveShareEvent: TrackableEvent {
    let eventKey = "receive_share"
    
    let address: String
    
    var parameters: [String: Any]? {
        return [
            "address": address
        ]
    }
}
