//
//  ReceiveTabEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveTabEvent: TrackableEvent {
    let eventKey = "tap_tab_receive"
    
    var parameters: [String: Any]? {
        return nil
    }
}
