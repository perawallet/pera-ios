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

//   CardsSupportedCountries.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class CardsSupportedCountries: ALGEntityModel {
    let currentRegion: CurrentRegion
    let regions: [SupportedRegion]

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.currentRegion = apiModel.currentRegion
        self.regions = apiModel.regions
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.currentRegion = currentRegion
        apiModel.regions = regions
        return apiModel
    }
}

extension CardsSupportedCountries {
    struct APIModel: ALGAPIModel {
        var currentRegion: CurrentRegion
        var regions: [SupportedRegion]

        init() {
            self.currentRegion = .init(countryCode: "MC", countryName: "Mock Country")
            self.regions = []
        }
        
        private enum CodingKeys: String, CodingKey {
            case currentRegion = "current_region"
            case regions
        }
    }
}

struct CurrentRegion: Codable {
    let countryCode: String
    let countryName: String
    
    private enum CodingKeys: String, CodingKey {
        case countryCode = "alpha_2"
        case countryName = "name"
    }
}

struct SupportedRegion: Codable {
    let country: SupportedCountry
    let isAvailable: Bool
    let liveStatus: String
    let nftImage: String?
    
    private enum CodingKeys: String, CodingKey {
        case country
        case isAvailable = "is_available"
        case liveStatus = "live_status"
        case nftImage = "nft_image"
    }
}

struct SupportedCountry: Codable {
    let countryCode: String
    let countryName: String
    
    private enum CodingKeys: String, CodingKey {
        case countryCode = "alpha_2_code"
        case countryName = "name"
    }
}
