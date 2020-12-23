//
//  CurrencyChangeEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct CurrencyChangeEvent: AnalyticsEvent {
    let currencyId: String
    
    let key: AnalyticsEventKey = .currencyChange
    
    var params: AnalyticsParameters? {
        return [.id: currencyId]
    }
}
