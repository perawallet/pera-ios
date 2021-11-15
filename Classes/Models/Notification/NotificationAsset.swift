// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  NotificationAsset.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class NotificationAsset: ALGResponseModel {
    var debugData: Data?

    let id: Int64?
    let name: String?
    let code: String?
    let url: String?
    let fractionDecimals: Int?

    init(_ apiModel: APIModel = APIModel()) {
        self.id = apiModel.assetId
        self.name = apiModel.assetName
        self.code = apiModel.unitName
        self.url = apiModel.url
        self.fractionDecimals = apiModel.fractionDecimals
    }
}

extension NotificationAsset {
    struct APIModel: ALGAPIModel {
        let assetId: Int64?
        let assetName: String?
        let unitName: String?
        let url: String?
        let fractionDecimals: Int?

        init() {
            self.assetId = nil
            self.assetName = nil
            self.unitName = nil
            self.url = nil
            self.fractionDecimals = nil
        }
    }
}
