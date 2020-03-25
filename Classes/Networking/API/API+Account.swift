//
//  API+Account.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    @discardableResult
    func fetchAccount(
        with draft: AccountFetchDraft,
        then handler: @escaping Endpoint.DefaultResultHandler<Account>
    ) -> EndpointOperatable {
        let address = draft.publicKey
        
        return Endpoint(path: Path("/v1/account/\(address)"))
            .httpMethod(.get)
            .httpHeaders(algorandAuthenticatedHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchDollarValue(
        then handler: @escaping Endpoint.DefaultResultHandler<AlgoToDollarConversion>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/v3/avgPrice"))
            .base(Environment.current.binanceApi)
            .httpMethod(.get)
            .query(DollarValueQuery())
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
