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

//   SwapQuickActionsViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SwapQuickActionsViewModel: ViewModel {
    private(set) var switchAssetsQuickActionItem: SwapQuickActionItem
    private(set) var adjustAmountQuickActionItem: SwapQuickActionItem
    private(set) var setMaxAmountQuickActionItem: SwapQuickActionItem

    init(amountPercentage: SwapAmountPercentage? = nil) {
        self.switchAssetsQuickActionItem = SwapSwitchAssetsQuickActionItem()
        self.adjustAmountQuickActionItem =
            Self.makeAdjustAmountQuickActionItem(percentage: amountPercentage)
        self.setMaxAmountQuickActionItem = SwapSetMaxAmountQuickActionItem()
    }
}

extension SwapQuickActionsViewModel {
    mutating func bind(amountPercentage: SwapAmountPercentage?) {
        bindAdjustAmountQuickActionItem(amountPercentage: amountPercentage)
    }

    mutating func bindAdjustAmountQuickActionItem(amountPercentage: SwapAmountPercentage?) {
        adjustAmountQuickActionItem = Self.makeAdjustAmountQuickActionItem(percentage: amountPercentage)
    }
}

extension SwapQuickActionsViewModel {
    private static func makeAdjustAmountQuickActionItem(percentage: SwapAmountPercentage?) -> SwapAdjustAmountQuickActionItem {
        let title = percentage.unwrap { $0.value.doubleValue.toPercentageWith(fractions: 2) }
        return SwapAdjustAmountQuickActionItem(title: title)
    }
}

struct SwapSwitchAssetsQuickActionItem: SwapQuickActionItem {
    let layout: Self.Layout
    let style: Self.Style
    let contentEdgeInsets: UIEdgeInsets

    init() {
        self.layout = .none
        self.style = [
            .icon([ .normal("swap-switch-icon") ])
        ]
        self.contentEdgeInsets = .init(top: 11, left: 16, bottom: 13, right: 16)
    }
}

struct SwapAdjustAmountQuickActionItem: SwapQuickActionItem {
    let layout: Self.Layout
    let style: Self.Style
    let contentEdgeInsets: UIEdgeInsets

    init(title: String? = nil) {
        self.layout = title.isNilOrEmpty ? .none : .imageAtRight(spacing: 4)
        self.style = [
            .font(Typography.captionBold()),
            .icon([
                .normal("swap-divider-customize-active-icon")
            ]),
            .title(title.someString),
            .titleColor([
                .normal(Colors.Helpers.positive)
            ])
        ]
        self.contentEdgeInsets = .init(top: 11, left: 16, bottom: 13, right: 12)
    }
}

struct SwapSetMaxAmountQuickActionItem: SwapQuickActionItem {
    let layout: Self.Layout
    let style: Self.Style
    let contentEdgeInsets: UIEdgeInsets

    init() {
        self.layout = .none
        self.style = [
            .title("send-transaction-max-button-title".localized),
            .font(Typography.captionBold()),
            .titleColor([
                .normal(Colors.Helpers.positive)
            ])
        ]
        self.contentEdgeInsets = .init(top: 11, left: 12, bottom: 13, right: 16)
    }
}
