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
    func getAssets(
        with draft: AssetFetchDraft,
        then handler: @escaping Endpoint.DefaultResultHandler<AssetList>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v1/assets"))
            .httpMethod(.get)
            .httpHeaders(algorandAuthenticatedHeaders())
            .query(AssetFetchQuery(assetId: draft.assetId.isEmpty ? 0 : Int(draft.assetId) ?? 0, max: draft.assetId.isEmpty ? 100 : 1))
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
