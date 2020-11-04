//
//  RegistrationEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct RegistrationEvent: TrackableEvent {
    let eventKey = "register"
    var parameters: [String: Any]? {
        return ["type": type.rawValue]
    }
    
    let type: RegistrationType
}

extension RegistrationEvent {
    enum RegistrationType: String {
        case create = "create"
        case ledger = "ledger"
        case recover = "recover"
        case rekeyed = "rekeyed"
        case watch = "watch"
    }
}
