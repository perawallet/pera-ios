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
    let thumbnailImage: URL?
    let medias: [Media]
    let title: String?
    let collectionName: String?
    let description: String?
    let traits: [CollectibleTrait]?
    let explorerURL: URL?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.mediaType = apiModel.mediaType
        self.thumbnailImage = apiModel.primaryImage

        var collectibleMedias: [Media] = []
        if let image = apiModel.primaryImage,
           mediaType == .image {
            collectibleMedias.append(
                Media(
                    type: .image,
                    sourceURL: image
                )
            )
        }

        if let video = apiModel.video,
           mediaType == .video {
            collectibleMedias.append(
                Media(
                    type: .video,
                    sourceURL: video
                )
            )
        }

        self.medias = collectibleMedias
        self.title = apiModel.title
        self.collectionName = apiModel.collectionName
        self.description = apiModel.description
        self.traits = apiModel.traits
        self.explorerURL = apiModel.explorerURL
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.mediaType = mediaType
        apiModel.primaryImage = thumbnailImage
        apiModel.video = medias.first(matching: (\.type, .video))?.sourceURL
        apiModel.title = title
        apiModel.collectionName = collectionName
        apiModel.description = description
        apiModel.traits = traits
        apiModel.explorerURL = explorerURL
        return apiModel
    }
}

extension Collectible {
    struct APIModel: ALGAPIModel {
        var mediaType: MediaType
        var primaryImage: URL?
        var video: URL?
        var title: String?
        var collectionName: String?
        var description: String?
        var traits: [CollectibleTrait]?
        var explorerURL: URL?

        init() {
            self.mediaType = .init()
            self.primaryImage = nil
            self.video = nil
            self.title = nil
            self.collectionName = nil
            self.description = nil
            self.traits = nil
            self.explorerURL = nil
        }

        private enum CodingKeys: String, CodingKey {
            case mediaType = "media_type"
            case primaryImage = "primary_image"
            case video
            case title
            case collectionName = "collection_name"
            case description
            case traits
            case explorerURL = "explorer_url"
        }
    }
}

enum MediaType:
    RawRepresentable,
    CaseIterable,
    Codable,
    Equatable {
    case image
    case video
    case unknown(String)

    var rawValue: String {
        switch self {
        case .image: return "image"
        case .video: return "video"
        case .unknown(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .image, .video
    ]

    init() {
        self = .unknown("")
    }

    init?(
        rawValue: String
    ) {
        let foundCase = Self.allCases.first { $0.rawValue == rawValue }
        self = foundCase ?? .unknown(rawValue)
    }

    var isSupported: Bool {
        if case .unknown = self {
            return false
        }

        return true
    }
}
