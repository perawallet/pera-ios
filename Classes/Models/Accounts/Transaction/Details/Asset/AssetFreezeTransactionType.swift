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
//  AssetFreezeTransaction.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AssetFreezeTransaction: ALGResponseModel {
    var debugData: Data?
    
    let address: String?
    let isFreeze: Bool?
    let assetId: Int64?

    init(_ apiModel: APIModel = APIModel()) {
        self.address = apiModel.address
        self.isFreeze = apiModel.newFreezeStatus
        self.assetId = apiModel.assetId
    }
}

extension AssetFreezeTransaction {
    struct APIModel: ALGAPIModel {
        let address: String?
        let newFreezeStatus: Bool?
        let assetId: Int64?

        init() {
            self.address = nil
            self.newFreezeStatus = nil
            self.assetId = nil
        }
    }
}
