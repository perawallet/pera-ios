//
//  SendTabEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct SendTabEvent: TrackableEvent {
    let eventKey = "tap_tab_send"
    
    var parameters: [String: Any]? {
        return nil
    }
}
