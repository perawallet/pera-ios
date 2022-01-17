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
//   AssetDetailInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetDetailInfoViewModel:
    ViewModel,
    Hashable {
    private(set) var isVerified: Bool = false
    private(set) var amount: String?
    private(set) var name: String?
    private(set) var ID: String?

    init(account: Account, assetDetail: AssetInformation) {
        bindName(from: assetDetail)
        bindAmount(from: assetDetail, in: account)
        bindID(from: assetDetail)
    }
}

extension AssetDetailInfoViewModel {
    private mutating func bindIsVerified(from assetDetail: AssetInformation) {
        isVerified = assetDetail.isVerified
    }

    private mutating func bindName(from assetDetail: AssetInformation) {
        name = assetDetail.getDisplayNames().0
    }

    private mutating func bindAmount(from assetDetail: AssetInformation, in account: Account) {
        guard let assetAmount = account.amount(for: assetDetail) else {
            return
        }
        amount = assetAmount.toFractionStringForLabel(fraction: assetDetail.decimals)
    }

    private mutating func bindID(from assetDetail: AssetInformation) {
        ID = "asset-detail-id-title".localized(params: "\(assetDetail.id)")
    }
}
