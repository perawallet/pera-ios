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

//   ALGAPI+PriceWatch.swift

import MagpieCore
import MagpieExceptions

extension ALGAPI {
    @discardableResult
    public func addAssetToPriceWatch(
        for deviceId: String,
        and assetId: String,
        onCompleted handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.addToPriceWatch, args: deviceId, assetId)
            .method(.post)
            .completionHandler(handler)
            .execute()
    }
    
    @discardableResult
    public func removeAssetFromPriceWatch(
        for deviceId: String,
        and assetId: String,
        onCompleted handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.removeFromPriceWatch, args: deviceId, assetId)
            .method(.post)
            .completionHandler(handler)
            .execute()
    }

    @discardableResult
    public func priceWatchStatus(
        for deviceId: String,
        and assetId: String,
        onCompleted handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.priceWatchStatus, args: deviceId, assetId)
            .method(.put)
            .completionHandler(handler)
            .execute()
    }

}
