//
//  API+Assets.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    @discardableResult
    func getAssetDetails(
        with draft: AssetFetchDraft,
        then handler: @escaping Endpoint.DefaultResultHandler<AssetDetail>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v1/asset/\(draft.assetId)"))
            .httpMethod(.get)
            .httpHeaders(algorandAuthenticatedHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func searchAssets(
        with draft: AssetSearchQuery,
        then handler: @escaping Endpoint.DefaultResultHandler<PaginatedList<AssetSearchResult>>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/assets/"))
            .httpMethod(.get)
            .base(Environment.current.mobileApi)
            .query(draft)
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func sendAssetSupportRequest(with draft: AssetSupportDraft) -> EndpointOperatable {
        return Endpoint(path: Path("/api/asset-requests/"))
            .httpMethod(.post)
            .base(Environment.current.mobileApi)
            .httpBody(draft)
            .buildAndSend(self)
    }
    
    @discardableResult
    func getVerifiedAssets(
        then handler: @escaping Endpoint.DefaultResultHandler<VerifiedAssetList>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/verified-assets/"))
            .httpMethod(.get)
            .base(Environment.current.mobileApi)
            .query(LimitQuery())
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
