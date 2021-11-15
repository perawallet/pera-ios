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
//   AlgorandBlock.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class AlgorandBlock: ALGResponseModel {
    var debugData: Data?

    let rewardsRate: UInt64
    let rewardsResidue: UInt64

    init(_ apiModel: APIModel = APIModel()) {
        self.rewardsRate = apiModel.block.rate
        self.rewardsResidue = apiModel.block.frac
    }
}

extension AlgorandBlock {
    struct APIModel: ALGAPIModel {
        let block: RewardsAPIModel

        init() {
            self.block = RewardsAPIModel()
        }
    }

    struct RewardsAPIModel: ALGAPIModel {
        let rate: UInt64
        let frac: UInt64

        init() {
            self.rate = 0
            self.frac = 0
        }
    }
}
