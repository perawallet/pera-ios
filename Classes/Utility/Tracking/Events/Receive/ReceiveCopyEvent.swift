//
//  ReceiveCopyEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveCopyEvent: TrackableEvent {
    var eventKey: String {
        return "receive_\(flow.rawValue)_copy"
    }
    
    let flow: ReceiveEventFlow
    let address: String
    
    var parameters: [String: Any]? {
        return [
            "address": address
        ]
    }
}
