//
//  RekeyEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct RekeyEvent: TrackableEvent {
    let eventKey = "rekey"
    
    var parameters: [String: Any]? {
        return nil
    }
}
