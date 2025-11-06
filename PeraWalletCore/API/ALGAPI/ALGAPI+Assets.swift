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
//  API+Assets.swift

import Foundation
import MagpieCore
import MagpieExceptions

extension ALGAPI {
    @discardableResult
    public func searchAssets(
        _ draft: AssetSearchQuery,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecorationList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assetSearch)
            .method(.get)
            .query(draft)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    public func searchAssetsForDiscover(
        draft: SearchAssetsForDiscoverDraft,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecorationList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assetSearch)
            .method(.get)
            .query(draft)
            .completionHandler(handler)
            .execute()
    }
    
    @discardableResult
    public func fetchAssetList(
        _ draft: AssetFetchQuery,
        queue: DispatchQueue,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecorationList>) -> Void
    ) -> EndpointOperatable {
        guard useAssetDetailV2Endpoint else {
            return fetchAssetListV1(draft, queue: queue, ignoreResponseOnCancelled: ignoreResponseOnCancelled, onCompleted: handler)
        }
        let draftV2 = AssetListFechDraft(ids: draft.ids, includeDeleted: draft.includeDeleted, deviceId: deviceId)
        return fetchAssetListV2(draftV2, queue: queue, ignoreResponseOnCancelled: ignoreResponseOnCancelled) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let list):
                handler(.success(list))
            case .failure(let apiError, _):
                analytics.record(.assetListV2Error(errorDescription: apiError.localizedDescription))
                fetchAssetListV1(draft, queue: queue, ignoreResponseOnCancelled: ignoreResponseOnCancelled, onCompleted: handler)
            }
        }
    }

    @discardableResult
    private func fetchAssetListV1(
        _ draft: AssetFetchQuery,
        queue: DispatchQueue,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecorationList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assets)
            .method(.get)
            .query(draft)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .responseDispatcher(queue)
            .execute()
    }
    
    @discardableResult
    private func fetchAssetListV2(
        _ draft: AssetListFechDraft,
        queue: DispatchQueue,
        ignoreResponseOnCancelled: Bool,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecorationList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV2(network))
            .path(.assets)
            .method(.post)
            .body(draft)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .responseDispatcher(queue)
            .execute()
    }
    
    @discardableResult
    public func fetchAssetDetail(
        _ draft: AssetDetailFetchDraft,
        ignoreResponseOnCancelled: Bool = true,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecoration>) -> Void
    ) -> EndpointOperatable {
        guard useAssetDetailV2Endpoint else {
            return fetchAssetDetailV1(draft, ignoreResponseOnCancelled: ignoreResponseOnCancelled, onCompleted: handler)
        }
        return fetchAssetDetailV2(draft, ignoreResponseOnCancelled: ignoreResponseOnCancelled) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let detail):
                handler(.success(detail))
            case .failure(let apiError, _):
                analytics.record(.assetDetailV2Error(errorDescription: apiError.localizedDescription))
                fetchAssetDetailV1(draft, ignoreResponseOnCancelled: ignoreResponseOnCancelled, onCompleted: handler)
            }
        }
    }

    @discardableResult
    public func fetchAssetDetailV1(
        _ draft: AssetDetailFetchDraft,
        ignoreResponseOnCancelled: Bool = true,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecoration>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assetDetail, args: "\(draft.id)")
            .method(.get)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .execute()
    }
    
    @discardableResult
    public func fetchAssetDetailV2(
        _ draft: AssetDetailFetchDraft,
        ignoreResponseOnCancelled: Bool = true,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecoration>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV2(network))
            .path(.assetDetail, args: "\(draft.id)")
            .method(.post)
            .body(draft)
            .ignoreResponseWhenEndpointCancelled(ignoreResponseOnCancelled)
            .completionHandler(handler)
            .execute()
    }
    
    @discardableResult
    public func fetchAssetDetailFromNode(
        _ draft: AssetDetailFetchDraft,
        onCompleted handler: @escaping (Response.ModelResult<AssetDecoration>) -> Void
    ) -> EndpointOperatable {
        let assetDetailHandler: (Response.ModelResult<AssetDetail>) -> Void = { response in
            switch response {
            case .failure(let apiError, let apiModel):
                handler(.failure(apiError, apiModel))
            case .success(let assetDetail):
                let decoration = AssetDecoration(assetDetail: assetDetail)
                handler(.success(decoration))
            }
        }
        
        return EndpointBuilder(api: self)
            .base(.algod(network))
            .path(.assetDetail, args: "\(draft.id)")
            .method(.get)
            .completionHandler(assetDetailHandler)
            .execute()
    }

    @discardableResult
    public func sendAssetSupportRequest(
        _ draft: AssetSupportDraft,
        onCompleted handler: @escaping (Response.Result<NoAPIModel, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.assetRequest)
            .method(.post)
            .body(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    public func getVerifiedAssets(onCompleted handler: @escaping (Response.ModelResult<VerifiedAssetList>) -> Void) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.verifiedAssets)
            .method(.get)
            .query(LimitQuery())
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    public func getTrendingAssets(onCompleted handler: @escaping (Response.ModelResult<[AssetDecoration.APIModel]>) -> Void) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.trendingAssets)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }
}
