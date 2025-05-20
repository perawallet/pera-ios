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

//   SpotBannersAPIDataController.swift

import Foundation

final class SpotBannersAPIDataController {
    weak var delegate: SpotBannersAPIDataControllerDelegate?
    
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
                self.delegate?.spotBannersAPIDataController(
                    self,
                    didFailFetch: apiError.localizedDescription,
                    spotBanners: banners
                )
            case .success(let spotBanners):
                banners.append(contentsOf: spotBanners.map { CarouselBannerItemModel(apiModel: $0)})

                self.delegate?.spotBannersAPIDataController(
                    self,
                    didFetch: banners
                )
            }
        }
    }
    
    func updateClose(for banner: CarouselBannerItemModel) {
        guard let deviceId = session.authenticatedUser?.getDeviceId(on: api.network) else {
            return
        }
        
        api.updateSpotBannerClose(deviceId: deviceId, bannerId: banner.id) { response in
            switch response {
            case .success:
                self.delegate?.spotBannersAPIDataController(
                    self,
                    didUpdate: banner
                )
            case .failure(let apiError, _):
                self.delegate?.spotBannersAPIDataController(
                    self,
                    didFailUpdateClose: apiError.localizedDescription
                )
            }
        }
        
    }
}

protocol SpotBannersAPIDataControllerDelegate: AnyObject {
    func spotBannersAPIDataController(
        _ dataController: SpotBannersAPIDataController,
        didFetch spotBanners: [CarouselBannerItemModel]
    )
    func spotBannersAPIDataController(
        _ dataController: SpotBannersAPIDataController,
        didFailFetch error: String, spotBanners: [CarouselBannerItemModel]
    )
    func spotBannersAPIDataController(
        _ dataController: SpotBannersAPIDataController,
        didUpdate spotBanner: CarouselBannerItemModel
    )
    func spotBannersAPIDataController(
        _ dataController: SpotBannersAPIDataController,
        didFailUpdateClose error: String
    )
}
