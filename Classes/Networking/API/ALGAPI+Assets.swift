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
//  API+Assets.swift

import Foundation
import MagpieCore

extension ALGAPI {
    @discardableResult
    func getAssetDetails(
        _ draft: AssetFetchDraft,
        onCompleted handler: @escaping (Response.ModelResult<AssetDetailResponse>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.indexer)
            .path(.assetDetail, args: "\(draft.assetId)")
            .method(.get)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func searchAssets(
        _ draft: AssetSearchQuery,
        onCompleted handler: @escaping (Response.ModelResult<AssetSearchResultList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobile)
            .path(.assets)
            .method(.get)
            .query(draft)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    func sendAssetSupportRequest(_ draft: AssetSupportDraft) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobile)
            .path(.assetRequest)
            .method(.post)
            .body(draft)
            .execute()
    }

    @discardableResult
    func getVerifiedAssets(onCompleted handler: @escaping (Response.ModelResult<VerifiedAssetList>) -> Void) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobile)
            .path(.verifiedAssets)
            .method(.get)
            .query(LimitQuery())
            .completionHandler(handler)
            .execute()
    }
}
