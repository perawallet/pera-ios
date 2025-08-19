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

//   Media.swift

import Foundation

public final class Media: ALGEntityModel {
    public let type: MediaType
    public let previewURL: URL?
    public let downloadURL: URL?
    public let mediaExtension: MediaExtension

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.type = apiModel.type
        self.previewURL = apiModel.previewURL.toURL()
        self.downloadURL = apiModel.downloadURL.toURL()
        self.mediaExtension = apiModel.mediaExtension ?? .init()
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.type = type
        apiModel.previewURL = previewURL?.absoluteString
        apiModel.downloadURL = downloadURL?.absoluteString
        apiModel.mediaExtension = mediaExtension
        return apiModel
    }
}

extension Media {
    public struct APIModel: ALGAPIModel {
        var type: MediaType
        var previewURL: String?
        var downloadURL: String?
        var mediaExtension: MediaExtension?

        public init() {
            self.type = .init()
            self.previewURL = nil
            self.downloadURL = nil
            self.mediaExtension = .init()
        }

        private enum CodingKeys: String, CodingKey {
            case type
            case previewURL = "preview_url"
            case downloadURL = "download_url"
            case mediaExtension = "extension"
        }
    }
}

extension Media {
    public var isGIF: Bool {
        return mediaExtension.isGIF
    }
}
