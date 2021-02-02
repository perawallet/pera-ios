//
//  CurrencyChangeEvent.swift

import Foundation

struct CurrencyChangeEvent: AnalyticsEvent {
    let currencyId: String
    
    let key: AnalyticsEventKey = .currencyChange
    
    var params: AnalyticsParameters? {
        return [.id: currencyId]
    }
}
