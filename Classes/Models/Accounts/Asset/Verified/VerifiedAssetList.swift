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
//  VerifiedAssetList.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class VerifiedAssetList: ALGResponseModel {
    var debugData: Data?
    
    let count: Int
    let next: String?
    let previous: String?
    let results: [VerifiedAsset]

    init(_ apiModel: APIModel = APIModel()) {
        self.count = apiModel.count
        self.next = apiModel.next
        self.previous = apiModel.previous
        self.results = apiModel.results.unwrapMap(VerifiedAsset.init)
    }
}

extension VerifiedAssetList {
    struct APIModel: ALGAPIModel {
        let count: Int
        let next: String?
        let previous: String?
        let results: [VerifiedAsset.APIModel]?

        init() {
            self.count = 0
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}
