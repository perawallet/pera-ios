// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapAssetSelectionViewModel.swift

import Foundation
import MacaroonUIKit

struct SwapAssetSelectionViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var verificationTier: Image?

    init(
        _ asset: Asset
    ) {
        bindTitle(asset)
        bindVerificationTier(asset)
    }
}

extension SwapAssetSelectionViewModel {
    mutating func bindTitle(
        _ asset: Asset
    ) {
        guard let unitName = asset.naming.unitName else {
            return
        }

        title = unitName.bodyRegular()
    }

    mutating func bindVerificationTier(
        _ asset: Asset
    ) {
        switch asset.verificationTier {
        case .trusted: verificationTier = "icon-trusted"
        case .verified: verificationTier = "icon-verified"
        case .unverified: verificationTier = nil
        case .suspicious: verificationTier = "icon-suspicious"
        }
    }
}
