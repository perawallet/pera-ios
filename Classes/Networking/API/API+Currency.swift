//
//  API+Currency.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

extension API {
    @discardableResult
    func getCurrencies(
        then handler: @escaping Endpoint.DefaultResultHandler<[Currency]>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/currencies/"))
            .base(mobileApiBase)
            .httpMethod(.get)
            .httpHeaders(mobileApiHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func getCurrencyValue(
        for currencyId: String,
        then handler: @escaping Endpoint.DefaultResultHandler<Currency>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/currencies/\(currencyId)"))
            .base(mobileApiBase)
            .httpMethod(.get)
            .httpHeaders(mobileApiHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
