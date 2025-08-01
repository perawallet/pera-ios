// Copyright 2022-2025 Pera Wallet, LDA

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

import Foundation
import MagpieCore
import MagpieHipo
import MagpieExceptions

extension ALGAPI {
    @discardableResult
    func fetchAccount(
        _ draft: AccountFetchDraft,
        includesClosedAccounts: Bool = false,
        queue: DispatchQueue,
        ignoreResponseOnCancelled: Bool,
        queryFilterOptions: AccountQueryOptions = [.assets],
        onCompleted handler: @escaping (Response.ModelResult<AccountApiResponse>) -> Void
    ) -> EndpointOperatable {
        var filterOptions = queryFilterOptions
        if includesClosedAccounts {
            filterOptions.insert(.includeAll)
        }
        return EndpointBuilder(api: self)
            .base(.indexer(network))
            .path(.accountDetail, args: draft.publicKey)
            .query(AccountQuery(options: filterOptions))
            .method(.get)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .responseDispatcher(queue)
            .execute()
    }

    @discardableResult
    func fetchAccountFromNode(
        _ draft: AccountFetchDraft,
        queue: DispatchQueue,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.ModelResult<Account>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.algod(network))
            .path(.accountDetail, args: draft.publicKey)
            .query(AccountQuery(options: [.excludeAll]))
            .method(.get)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .responseDispatcher(queue)
            .execute()
    }

    @discardableResult
    func fetchRekeyedAccounts(
        _ account: String,
        onCompleted handler: @escaping (Response.ModelResult<RekeyedAccountsResponse>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.indexer(network))
            .path(.accounts)
            .method(.get)
            .query(RekeyedAccountQuery(authAddress: account))
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func fetchBackupDetail(
        _ backupID: String,
        onCompleted handler: @escaping (Response.Result<Backup, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.backups, args: backupID)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func fetchAccountAssetFromNode(
        _ draft: AccountAssetFetchDraft,
        queue: DispatchQueue,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.ModelResult<AccountAssetInformation>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.algod(network))
            .path(.accountAsset, args: draft.publicKey, String(draft.assetID))
            .method(.get)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .responseDispatcher(queue)
            .execute()
    }
    
    @discardableResult
    func fetchAccountFastLookup(
        _ address: String,
        onCompleted handler: @escaping (Response.ModelResult<AccountFastLookup>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.fastLookup, args: address)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }
}
