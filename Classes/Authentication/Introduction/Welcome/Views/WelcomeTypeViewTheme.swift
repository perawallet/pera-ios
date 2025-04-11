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

//   WelcomeTypeViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

struct WelcomeTypeViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let detail: TextStyle
    let contentView: ViewStyle
    let arrowIcon: ImageStyle

    let iconSize: LayoutSize
    let iconInsets: LayoutPaddings
    let contentViewInsets: LayoutPaddings
    let titleHorizontalInset: LayoutMetric
    let detailHorizontalInset: LayoutMetric
    let detailHeight: LayoutMetric
    let arrowIconHorizontalInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.title = [
            .textOverflow(FittingText()),
            .font(Typography.bodyLargeMedium()),
            .textColor(Colors.Text.main),
            .textAlignment(.left),
            .isInteractable(false)
        ]
        self.detail = [
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(Colors.Text.gray),
            .textAlignment(.left),
            .isInteractable(false)
        ]
        self.contentView = [
            .backgroundColor(Colors.Button.Ghost.focusBackground),
            .isInteractable(false)
        ]
        self.arrowIcon = [
            .image("icon-arrow-24"),
            .isInteractable(false)
        ]

        self.iconSize = (24, 24)
        self.iconInsets = (18, 16, 18, 12)
        self.titleHorizontalInset = 12
        self.detailHorizontalInset = 24
        self.detailHeight = 24
        self.contentViewInsets = (-12, 16, 0, 16)
        self.arrowIconHorizontalInset = 16
    }
}
