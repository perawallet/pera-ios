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

//   SelectorOption.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SelectorOption: Segment {
    let layout: Self.Layout
    let style: Self.Style
    let contentEdgeInsets: UIEdgeInsets

    init(
        title: String
    ) {
        self.layout = .none
        self.style = [
            .title(title.localized),
            .titleColor([
                .normal(Colors.Button.Secondary.text),
                .highlighted(Colors.Helpers.positive),
                .selected(Colors.Helpers.positive)
            ]),
            .font(Typography.footnoteMedium()),
            .backgroundImage([
                .normal("swap-selector-background-normal"),
                .highlighted("swap-selector-background-selected"),
                .selected("swap-selector-background-selected")
            ])
        ]
        self.contentEdgeInsets = .zero
    }
}
