//
//  API+Assets.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension AlgorandAPI {
    @discardableResult
    func getAssetDetails(
        with draft: AssetFetchDraft,
        then handler: @escaping (Response.ModelResult<AssetDetailResponse>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(indexerBase)
            .path("/v2/assets/\(draft.assetId)")
            .headers(indexerAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func searchAssets(
        with draft: AssetSearchQuery,
        then handler: @escaping (Response.ModelResult<PaginatedList<AssetSearchResult>>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .headers(mobileApiHeaders())
            .query(draft)
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func sendAssetSupportRequest(with draft: AssetSupportDraft) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/asset-requests/")
            .method(.post)
            .headers(mobileApiHeaders())
            .body(draft)
            .build()
            .send()
    }
    
    @discardableResult
    func getVerifiedAssets(
        then handler: @escaping (Response.ModelResult<VerifiedAssetList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/verified-assets/")
            .headers(mobileApiHeaders())
            .query(LimitQuery())
            .completionHandler(handler)
            .build()
            .send()
    }
}
