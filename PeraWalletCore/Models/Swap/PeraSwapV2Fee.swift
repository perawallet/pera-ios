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

//   PeraSwapV2Fee.swift

import Foundation
import MagpieCore

public final class PeraSwapV2Fee: ALGEntityModel {
    public let fee: UInt64?
    public let assetId: UInt64?

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.fee = apiModel.peraFeeAmount.unwrap { UInt64($0) }
        self.assetId = apiModel.peraFeeAssetId.unwrap { UInt64($0) }
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.peraFeeAmount = fee.unwrap { $0 }
        apiModel.peraFeeAssetId = assetId.unwrap { $0 }
        return apiModel
    }
}

extension PeraSwapV2Fee {
    public struct APIModel: ALGAPIModel {
        var peraFeeAmount: UInt64?
        var peraFeeAssetId: UInt64?

        public init() {
            self.peraFeeAmount = nil
            self.peraFeeAssetId = nil
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case peraFeeAmount = "pera_fee_amount"
            case peraFeeAssetId = "pera_fee_asset_id"
        }
    }
}
