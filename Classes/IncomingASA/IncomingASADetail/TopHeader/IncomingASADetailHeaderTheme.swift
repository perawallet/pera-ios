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

//   IncomingASADetailHeaderTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct IncomingASADetailHeaderTheme: StyleSheet, LayoutSheet {
    let height: LayoutMetric
    let backgroundColor: Color
    let accountItem: PrimaryAccountListItemViewTheme
    let accountTopInset: LayoutMetric
    let accountAssetViewTopInset: LayoutMetric
    let divider: ViewStyle
    let dividerLeadingInset: LayoutMetric
    let dividerTopInset: LayoutMetric
    let dividerHeight: LayoutMetric
    let assetItem: IncomingASAItemViewTheme
    let infoIconSize: LayoutSize
    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.height = 200
        self.backgroundColor = Colors.Defaults.black
        self.accountItem = IncomingASAAccountListItemViewTheme()
        self.accountTopInset = 16
        self.accountAssetViewTopInset = 64
        self.divider = [
            .backgroundColor(Colors.Button.Helper.background)
        ]
        self.dividerLeadingInset = 48
        self.dividerTopInset = 20
        self.dividerHeight = 1
        self.assetItem = IncomingASAItemViewTheme()
        self.infoIconSize = (24, 24)
        self.horizontalInset = 16
        self.verticalInset = 16
    }
}


struct IncomingASAAccountListItemViewTheme: PrimaryAccountListItemViewTheme {
    var icon: ImageStyle
    var iconSize: LayoutSize
    var iconBottomRightBadgePaddings: LayoutPaddings
    var horizontalPadding: LayoutMetric
    var contentMinWidthRatio: LayoutMetric
    var title: PrimaryTitleViewTheme
    var primaryAccessory: TextStyle
    var secondaryAccessory: TextStyle
    var accessoryIcon: ImageStyle
    var accessoryIconContentEdgeInsets: LayoutOffset

    init(_ family: LayoutFamily) {
        self.icon = [
            .contentMode(.scaleAspectFit)
        ]
        self.iconSize = (40, 40)
        self.iconBottomRightBadgePaddings = (20, 20, .noMetric, .noMetric)
        self.horizontalPadding = 16
        self.contentMinWidthRatio = 0.25
        self.title = IncomingASAAccountPreviewPrimaryTitleViewTheme(family)
        self.primaryAccessory = [
            .textColor(Colors.Text.mainDark)
        ]
        self.secondaryAccessory = [
            .textColor(Colors.Text.grayLighter)
        ]
        self.accessoryIcon = [
            .contentMode(.right)
        ]
        self.accessoryIconContentEdgeInsets = (8, 0)
    }
}

fileprivate struct IncomingASAAccountPreviewPrimaryTitleViewTheme: PrimaryTitleViewTheme {
    var primaryTitle: TextStyle
    let primaryTitleAccessory: ImageStyle
    let primaryTitleAccessoryContentEdgeInsets: LayoutOffset
    var secondaryTitle: TextStyle
    let spacingBetweenPrimaryAndSecondaryTitles: LayoutMetric

    init(_ family: LayoutFamily) {
        self.primaryTitle = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.mainDark)
        ]
        self.primaryTitleAccessory = []
        self.primaryTitleAccessoryContentEdgeInsets = (0, 0)
        self.secondaryTitle = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayDark)
        ]
        self.spacingBetweenPrimaryAndSecondaryTitles = 0
    }
}
