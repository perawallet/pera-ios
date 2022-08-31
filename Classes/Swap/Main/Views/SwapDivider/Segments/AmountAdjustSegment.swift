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

//   AmountAdjustSegment.swift

import UIKit
import MacaroonUIKit

struct AmountAdjustSegment: Segment {
    let layout: Button.Layout
    var style: ButtonStyle
    let contentEdgeInsets: UIEdgeInsets?

    init() {
        self.layout = .none
        self.style = [
            .icon([
                .normal("swap-divider-customize-active-icon"),
                .selected("swap-divider-customize-active-icon")
            ])
        ]
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 12)
    }

    init(title: String) {
        self.layout = .imageAtRight(spacing: 4)
        self.style = [
            .icon([
                .normal("swap-divider-customize-active-icon"),
                .selected("swap-divider-customize-active-icon")
            ]),
            .title(title),
            .font(Typography.captionBold()),
            .titleColor([
                .normal(Colors.Helpers.positive),
                .selected(Colors.Helpers.positive)
            ])
        ]
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 12)
    }

    mutating func configureForDisabledState() {
        self.style.icon = [
            .normal("swap-divider-customize-deactive-icon"),
            .selected("swap-divider-customize-deactive-icon")
        ]
        self.style.titleColor = [
            .normal(Colors.Text.gray),
            .selected(Colors.Text.gray)
        ]
    }
}
