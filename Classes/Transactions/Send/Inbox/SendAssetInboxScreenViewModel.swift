// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SendAssetInboxScreenViewModel.swift

import Foundation
import MacaroonUIKit

struct SendAssetInboxScreenViewModel {
    private(set) var title: TextProvider?
    private(set) var description: TextProvider?
    private(set) var subtitle: TextProvider?
    private(set) var highlightedSubtitleText: HighlightedText?
    private(set) var assetInformationViewModel: ARC59SendAssetInformationViewModel?
    private(set) var feeInformationViewModel: ARC59SendFeeInformationViewModel?

    init(
        asset: Asset?,
        amount: Decimal?,
        fee: UInt64?
    ) {
        bindTitle()
        bindSubtitle()
        bindHighlightedSubtitleText()
        bindAssetInformation(
            asset: asset,
            amount: amount
        )
        bindFeeInformation(fee)
        bindDescription()
    }
}

extension SendAssetInboxScreenViewModel {
    private mutating func bindTitle() {
        title = "send-inbox-title".localized.bodyMedium(alignment: .center)
    }
    
    private mutating func bindSubtitle() {
        subtitle = "send-inbox-description".localized.footnoteRegular(alignment: .center)
    }

    private mutating func bindHighlightedSubtitleText() {
        var attributes = Typography.footnoteMediumAttributes()
        attributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        highlightedSubtitleText = HighlightedText(
            text: "send-inbox-read-more".localized,
            attributes: attributes
        )
    }
    
    mutating func bindAssetInformation(
        asset: Asset?,
        amount: Decimal?
    ) {
        assetInformationViewModel = ARC59SendAssetInformationViewModel(
            asset: asset,
            amount: amount
        )
    }
    
    mutating func bindFeeInformation(_ fee: UInt64?) {
        feeInformationViewModel = ARC59SendFeeInformationViewModel(fee: fee)
    }
    
    private mutating func bindDescription() {
        description = "send-inbox-fee-description".localized.footnoteRegular()
    }
}

extension SendAssetInboxScreenViewModel {
    struct HighlightedText {
        let text: String
        let attributes: TextAttributeGroup
    }
}
