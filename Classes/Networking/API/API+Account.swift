// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
