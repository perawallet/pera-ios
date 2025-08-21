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

//   SpotBannersAPIDataController.swift

import Foundation
import pera_wallet_core

final class SpotBannersAPIDataController {
    var onFetch: ((String?, [CarouselBannerItemModel]) -> Void)?
    var onUpdateClose: ((String?) -> Void)?
    
    private let api: ALGAPI
    private let session: Session
    
    init(api: ALGAPI, session: Session) {
        self.api = api
        self.session = session
    }
    
    func loadData(shouldAddBackupBanner: Bool) {
        guard let deviceId = session.authenticatedUser?.getDeviceId(on: api.network) else {
            return
        }
        var banners: [CarouselBannerItemModel] = []
        if shouldAddBackupBanner {
            banners.append(CarouselBannerItemModel())
        }
        
        api.fetchSpotBannersList(deviceId: deviceId) { [weak self] response in
            guard let self else { return }
            switch response {
            case .failure(let apiError, _):
                onFetch?(apiError.localizedDescription, banners)
            case .success(let spotBanners):
                banners.append(contentsOf: spotBanners.map { CarouselBannerItemModel(apiModel: $0)})
                onFetch?(nil, banners)
            }
        }
    }
    
    func updateClose(for banner: CarouselBannerItemModel) {
        guard let deviceId = session.authenticatedUser?.getDeviceId(on: api.network) else {
            return
        }
        
        api.updateSpotBannerClose(deviceId: deviceId, bannerId: banner.id) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success:
                onUpdateClose?(nil)
            case .failure(let apiError, _):
                onUpdateClose?(apiError.localizedDescription)
            }
        }
        
    }
}
