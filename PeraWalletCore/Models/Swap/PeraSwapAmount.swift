// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   PeraSwapAmount.swift

import Foundation
import MagpieCore

public final class PeraSwapAmount: ALGEntityModel {
    public let amount: UInt64?
    public let peraFee: UInt64?
    public let peraFeeAsset: AssetDecoration?
    public let peraFeeAmountInFeeAsset: UInt64?
    public let peraFeeAssetId: UInt64?

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.amount = UInt64(apiModel.amount.unwrap(or: "0"))
        self.peraFee = UInt64(apiModel.peraFee.unwrap(or: "0"))
        self.peraFeeAsset = apiModel.peraFeeAsset.unwrap(AssetDecoration.init)
        self.peraFeeAmountInFeeAsset = UInt64(apiModel.peraFeeAmountInFeeAsset.unwrap(or: "0"))
        self.peraFeeAssetId = apiModel.peraFeeAssetId.unwrap { UInt64($0) }
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.amount = amount.unwrap { String(describing: $0) }
        apiModel.peraFee = peraFee.unwrap { String(describing: $0) }
        apiModel.peraFeeAsset = peraFeeAsset?.encode()
        apiModel.peraFeeAmountInFeeAsset = peraFeeAmountInFeeAsset.unwrap { String(describing: $0) }
        apiModel.peraFeeAssetId = peraFeeAssetId.unwrap { $0 }
        return apiModel
    }
}

extension PeraSwapAmount {
    public struct APIModel: ALGAPIModel {
        var amount: String? = nil
        var peraFee: String? = nil
        var peraFeeAsset: AssetDecoration.APIModel? = nil
        var peraFeeAmountInFeeAsset: String? = nil
        var peraFeeAssetId: UInt64? = nil

        public init() {}

        private enum CodingKeys:
            String,
            CodingKey {
            case amount
            case peraFee = "pera_fee_amount"
            case peraFeeAsset = "pera_fee_asset"
            case peraFeeAmountInFeeAsset = "pera_fee_amount_in_fee_asset"
            case peraFeeAssetId = "pera_fee_asset_id"
        }
    }
}
