//
//  RegistrationEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct RegistrationEvent: AnalyticsEvent {
    let type: RegistrationType
    
    let key: AnalyticsEventKey = .register
    
    var params: AnalyticsParameters? {
        return [.type: type.rawValue]
    }
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
