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

//   ARC59SendFeeInformationViewModel.swift

import MacaroonUIKit

struct ARC59SendFeeInformationViewModel: SecondaryListItemViewModel {
    var title: TextProvider?
    var accessory: SecondaryListItemValueViewModel?

    init(
        fee: UInt64?
    ) {
        bindTitle()
        bindAccessory(fee)
    }
}

extension ARC59SendFeeInformationViewModel {
    private mutating func bindTitle() {
        var attributes = Typography.bodyRegularAttributes(lineBreakMode: .byWordWrapping)
        attributes.insert(.textColor(Colors.Text.gray))

        title =
            String(localized: "send-inbox-fee-title")
                .attributed(attributes)
    }

    private mutating func bindAccessory(_ fee: UInt64?) {
        guard let fee else { return }
        
        accessory = ARC59SendFeeInformationItemValueViewModel(fee: fee)
    }
}

private struct ARC59SendFeeInformationItemValueViewModel: SecondaryListItemValueViewModel {
    var icon: ImageStyle?
    var title: TextProvider?

    init(
        fee: UInt64
    ) {
        bindTitle(fee)
    }
}

private extension ARC59SendFeeInformationItemValueViewModel {
    mutating func bindTitle(_ fee: UInt64) {
        let formatter = CurrencyFormatter()
        formatter.formattingContext = .standalone()
        formatter.currency = AlgoLocalCurrency()
        let unformattedFee = fee.toAlgos
        let formattedFee = formatter.format(unformattedFee)

        var attributes = Typography.bodyRegularAttributes(
            lineBreakMode: .byTruncatingTail
        )

        attributes.insert(.textColor(Colors.Text.main))

        title =
            (formattedFee ?? "\(unformattedFee)")
                .attributed(
                    attributes
                )
    }
}
