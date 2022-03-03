// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   Collectible.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class Collectible: ALGEntityModel {
    let mediaType: MediaType
    let primaryImage: URL?
    let title: String?
    let collectionName: String?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.mediaType = apiModel.mediaType
        self.primaryImage = apiModel.primaryImage
        self.title = apiModel.title
        self.collectionName = apiModel.collectionName
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.mediaType = mediaType
        apiModel.primaryImage = primaryImage
        apiModel.title = title
        apiModel.collectionName = collectionName
        return apiModel
    }
}

extension Collectible {
    struct APIModel: ALGAPIModel {
        var mediaType: MediaType
        var primaryImage: URL?
        var title: String?
        var collectionName: String?

        init() {
            self.mediaType = .unknown
            self.primaryImage = nil
            self.title = nil
            self.collectionName = nil
        }

        private enum CodingKeys: String, CodingKey {
            case mediaType = "media_type"
            case primaryImage = "primary_image"
            case title
            case collectionName = "collection_name"
        }
    }
}

enum MediaType: String, Codable {
    case image
    case unknown
}
