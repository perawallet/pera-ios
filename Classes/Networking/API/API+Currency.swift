//
//  API+Currency.swift

import Magpie

extension AlgorandAPI {
    @discardableResult
    func getCurrencies(
        then handler: @escaping (Response.ModelResult<[Currency]>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/currencies/")
            .headers(mobileApiHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func getCurrencyValue(
        for currencyId: String,
        then handler: @escaping (Response.ModelResult<Currency>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/currencies/\(currencyId)")
            .headers(mobileApiHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
}
