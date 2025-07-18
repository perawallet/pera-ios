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

//   SpotBannerListItem.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class SpotBannerListItem: ALGEntityModel, Codable {
    let id: Int
    let text: String
    let image: String
    let url: String
    let buttonUrlIsExternal: Bool

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        id = apiModel.id
        text = apiModel.text
        image = apiModel.image
        url = apiModel.url
        buttonUrlIsExternal = apiModel.buttonUrlIsExternal
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        
        apiModel.id = id
        apiModel.text = text
        apiModel.image = image
        apiModel.url = url
        apiModel.buttonUrlIsExternal = buttonUrlIsExternal
        return apiModel
    }
}

extension SpotBannerListItem {
    struct APIModel: ALGAPIModel, Codable {
        var id: Int
        var text: String
        var image: String
        var url: String
        var buttonUrlIsExternal: Bool

        init() {
            self.id = 0
            self.text = .empty
            self.image = .empty
            self.url = .empty
            self.buttonUrlIsExternal = false
        }
        
        private enum CodingKeys: String, CodingKey {
            case id
            case text
            case image
            case url
            case buttonUrlIsExternal = "button_url_is_external"
        }
    }
}
