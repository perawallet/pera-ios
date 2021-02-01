//
//  API+Account.swift

import Magpie

extension AlgorandAPI {
    @discardableResult
    func fetchAccount(
        with draft: AccountFetchDraft,
        then handler: @escaping (Response.ModelResult<AccountResponse>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(indexerBase)
            .path("/v2/accounts/\(draft.publicKey)")
            .headers(indexerAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func fetchRekeyedAccounts(
        of account: String,
        then handler: @escaping (Response.ModelResult<RekeyedAccountsResponse>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(indexerBase)
            .path("/v2/accounts")
            .query(RekeyedAccountQuery(authAddress: account))
            .headers(indexerAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
}
