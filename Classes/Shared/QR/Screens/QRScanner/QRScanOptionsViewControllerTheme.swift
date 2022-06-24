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

//   QRScanOptionsViewControllerTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct QRScanOptionsViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    let addressContainerCorner: Corner
    let addressContainerBorder: Border
    let addressContainerShadow: MacaroonUIKit.Shadow
    let addressTitle: TextStyle
    let addressValue: TextStyle

    var background: ViewStyle
    var verticalPadding: LayoutMetric
    var addressContextPaddings: LayoutPaddings
    var addressTitlePaddings: LayoutPaddings
    var addressValuePaddings: LayoutPaddings
    var optionContextPaddings: LayoutPaddings
    var addressValueOffset: LayoutMetric
    var separator: Separator
    var separatorPadding: LayoutMetric
    var action: ListActionViewTheme

    init(
        _ family: LayoutFamily
    ) {
        addressContainerCorner = Corner(radius: 4)
        addressContainerBorder = Border(color: AppColors.SendTransaction.Shadow.first.uiColor, width: 1)
        addressContainerShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.first.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        addressTitle = [
            .textColor(AppColors.Components.Text.grayLighter),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]
        addressValue = [
            .textColor(AppColors.Components.Text.main),
            .textAlignment(.left),
            .textOverflow(FittingText())
        ]

        background = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
        verticalPadding = 20
        let horizontalPadding: LayoutMetric = 20
        addressContextPaddings = (verticalPadding, horizontalPadding, .noMetric, horizontalPadding)
        let addressVerticalPadding: LayoutMetric = 16
        addressTitlePaddings = (addressVerticalPadding, horizontalPadding, .noMetric, horizontalPadding)
        addressValuePaddings = (.noMetric, horizontalPadding, addressVerticalPadding, horizontalPadding)
        optionContextPaddings = (verticalPadding, horizontalPadding, verticalPadding, horizontalPadding)
        addressValueOffset = 4
        separator = Separator(
            color: AppColors.Shared.Layer.grayLighter,
            size: 1,
            position: .bottom((60, horizontalPadding))
        )
        separatorPadding = 2
        action = ListActionViewTheme(family)
        action.configureForQRScanOptionsView()
    }
}
