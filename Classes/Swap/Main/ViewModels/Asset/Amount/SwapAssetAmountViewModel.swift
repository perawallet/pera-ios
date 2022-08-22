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

//   SwapAssetAmountViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapAssetAmountViewModel: ViewModel {
    private(set) var leftTitle: TextProvider?
    private(set) var rightTitle: TextProvider?
    private(set) var assetAmountValue: AssetAmountInputViewModel?
    private(set) var assetSelectionValue: SwapAssetSelectionViewModel?

    init(
        _ draft: SwapAssetAmountViewModelDraft
    ) {
        bindLeftTitle(draft)
        bindRightTitle(draft)
        bindAssetAmountValue(draft)
        bindAssetSelectionValue(draft)
    }
}

extension SwapAssetAmountViewModel {
    mutating func bindLeftTitle(
        _ draft: SwapAssetAmountViewModelDraft
    ) {
        if let title = draft.leftTitle {
            leftTitle = title.footnoteRegular(
                alignment: .left,
                lineBreakMode: .byTruncatingTail
            )
        } else {
            leftTitle = nil
        }
    }

    mutating func bindRightTitle(
        _ draft: SwapAssetAmountViewModelDraft
    ) {
        if let title = draft.rightTitle {
            rightTitle = title.footnoteRegular(
                alignment: .right,
                lineBreakMode: .byTruncatingTail
            )
        } else {
            rightTitle = nil
        }
    }

    mutating func bindAssetAmountValue(
        _ draft: SwapAssetAmountViewModelDraft
    ) {
        assetAmountValue = AssetAmountInputViewModel(
            asset: draft.asset,
            isInputEditable: draft.isInputEditable
        )
    }

    mutating func bindAssetSelectionValue(
        _ draft: SwapAssetAmountViewModelDraft
    ) {
        assetSelectionValue = SwapAssetSelectionViewModel(draft.asset)
    }
}
