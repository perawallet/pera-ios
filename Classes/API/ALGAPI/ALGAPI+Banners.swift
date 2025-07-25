// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ALGAPI+Banners.swift

import MagpieCore

extension ALGAPI {
    @discardableResult
    func fetchSpotBannersList(
        deviceId: String,
        onCompleted handler: @escaping (Response.ModelResult<[SpotBannerListItem.APIModel]>) -> Void
    ) -> EndpointOperatable {
        EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.spotBannersList, args: deviceId)
            .method(.get)
            .completionHandler(handler)
            .execute()
    }
    
    @discardableResult
    func updateSpotBannerClose(
        deviceId: String,
        bannerId: Int,
        onCompleted handler: @escaping (Response.ModelResult<SpotBannerListItem>) -> Void
    ) -> EndpointOperatable {
        EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.spotBannerClose, args: deviceId, bannerId)
            .method(.patch)
            .completionHandler(handler)
            .execute()
    }
}
