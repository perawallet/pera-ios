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
        then handler: @escaping Endpoint.CompleteResultHandler<AccountResponse, IndexerError>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v2/accounts/\(draft.publicKey)"))
            .base(indexerBase)
            .httpMethod(.get)
            .httpHeaders(indexerAuthenticatedHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchRekeyedAccounts(
        of account: String,
        then handler: @escaping Endpoint.DefaultResultHandler<RekeyedAccountsResponse>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v2/accounts"))
            .base(indexerBase)
            .httpMethod(.get)
            .query(RekeyedAccountQuery(authAddress: account))
            .httpHeaders(indexerAuthenticatedHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
