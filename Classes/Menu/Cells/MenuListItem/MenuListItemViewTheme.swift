// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MenuListItemViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct MenuListItemViewTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let contentViewRadius: LayoutMetric
    let title: TextStyle
    let titleHorizontalPadding: LayoutMetric
    let iconHorizontalPadding: LayoutMetric
    let arrow: ImageStyle
    let newLabel: TextStyle
    let newLabelSize: LayoutSize
    let newLabelRadius: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Button.Ghost.focusBackground)
        ]
        self.contentViewRadius = 16
        
        self.title = [
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        self.titleHorizontalPadding = 12
        
        self.iconHorizontalPadding = 16
        
        self.arrow = [
            .image("icon-arrow-24")
        ]
        
        self.newLabel = [
            .backgroundColor(Colors.Wallet.wallet4),
            .textColor(Colors.Wallet.wallet4Icon),
            .font(Typography.captionMedium()),
            .textAlignment(.center),
            .text(String(localized: "title-new-uppercased"))
        ]
        self.newLabelSize = (41, 28)
        self.newLabelRadius = 8
    }
}
