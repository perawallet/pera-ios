//
//  CurrencyChangeEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct CurrencyChangeEvent: TrackableEvent {
    let eventKey = "currency_change"
    
    let currencyId: String
    
    var parameters: [String: Any]? {
        return [
            "id": currencyId
        ]
    }
}
