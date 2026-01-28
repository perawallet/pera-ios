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

//   SwapProviderV2.swift

import Foundation

public final class SwapProviderV2: ALGEntityModel {

    public let name: String
    public let displayName: String
    public let iconUrl: String

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.name = apiModel.name
        self.displayName = apiModel.displayName
        self.iconUrl = apiModel.iconUrl
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.name = name
        apiModel.displayName = displayName
        apiModel.iconUrl = iconUrl
        return apiModel
    }
}

extension SwapProviderV2 {
    public struct APIModel: ALGAPIModel {
        var name: String
        var displayName: String
        var iconUrl: String

        public init() {
            self.name = .empty
            self.displayName = .empty
            self.iconUrl = .empty
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case name
            case displayName = "display_name"
            case iconUrl = "icon_url"
        }
    }
}

extension SwapProviderV2 {
    static func mock() -> SwapProviderV2 {
        var apiModel = APIModel()
        apiModel.name = "MockProvider"
        apiModel.displayName = "MockProvider"
        apiModel.iconUrl = .empty
        return SwapProviderV2(apiModel)
    }
}
