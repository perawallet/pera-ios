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

//   PeraInroductionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PeraInroductionViewTheme:
    StyleSheet,
    LayoutSheet {
    let closeButton: ButtonStyle
    let topViewContainer: ViewStyle
    let peraLogoImageView: ImageStyle
    let firstTitleLabel: TextStyle
    let secondTitleLabel: TextStyle
    let descriptionLabel: TextStyle
    let actionButton: ButtonStyle
    let actionButtonContentEdgeInsets: LayoutPaddings
    let actionButtonCorner: Corner

    let horizontalPadding: LayoutMetric
    let bottomPadding: LayoutMetric
    let topContainerMaxHeight: LayoutMetric
    let peraLogoMaxSize: LayoutSize
    let peraLogoMinSize: LayoutSize
    let topContainerMinHeight: LayoutMetric
    let firstTitleLabelTopPadding: LayoutMetric
    let secondTitleLabelTopPadding: LayoutMetric
    let descriptionLabelTopPadding: LayoutMetric
    let closeButtonSize: LayoutSize
    let closeButtonTopPadding: LayoutMetric
    let linearGradientHeight: LayoutMetric
    
    init(
        _ family: LayoutFamily
    ) {
        let closeButtonIcon = "icon-close".uiImage.withRenderingMode(.alwaysTemplate)
        closeButton = [
            .icon([.normal(closeButtonIcon)]),
            .tintColor(UIColor.black)
        ]
        topViewContainer = [
            .backgroundColor(AppColors.Shared.Global.yellow400)
        ]
        peraLogoImageView = [
            .image("icon-logo"),
            .contentMode(.scaleAspectFit)
        ]

        let firstTitleLabelFont = Fonts.DMSans.medium.make(15).uiFont
        let firstTitleLabelLineHeightMultiplier = 1.23
        firstTitleLabel = [
            .text(
                "pera-announcement-title"
                    .localized
                    .attributed(
                        [
                            .font(firstTitleLabelFont),
                            .lineHeightMultiplier(firstTitleLabelLineHeightMultiplier, firstTitleLabelFont),
                            .paragraph([
                                .textAlignment(.left),
                                .lineBreakMode(.byWordWrapping),
                                .lineHeightMultiple(firstTitleLabelLineHeightMultiplier)
                            ]),
                        ]
                    )
            ),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]

        let secondTitleLabelFont = Fonts.DMSans.medium.make(32).uiFont
        let secondTitleLabelLineHeightMultiplier = 0.96
        secondTitleLabel = [
            .text(
                "pera-announcement-subtitle"
                    .localized
                    .attributed(
                        [
                            .font(secondTitleLabelFont),
                            .lineHeightMultiplier(secondTitleLabelLineHeightMultiplier, secondTitleLabelFont),
                            .paragraph([
                                .textAlignment(.left),
                                .lineBreakMode(.byWordWrapping),
                                .lineHeightMultiple(secondTitleLabelLineHeightMultiplier)
                            ]),
                        ]
                    )
            ),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]

        actionButton = [
            .title("tutorial-main-title-ledger-connected".localized),
            .titleColor([ .normal(AppColors.Components.Button.Secondary.text) ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundColor(AppColors.Components.Button.Secondary.background)
        ]
        actionButtonContentEdgeInsets = (14, 0, 14, 0)
        actionButtonCorner = Corner(radius: 4)

        let descriptionLabelFont = Fonts.DMSans.regular.make(15).uiFont
        let descriptionLabelLineHeightMultiplier = 1.23
        descriptionLabel = [
            .text(
                "pera-announcement-description"
                    .localized
                    .attributed([
                        .font(descriptionLabelFont),
                        .lineHeightMultiplier(descriptionLabelLineHeightMultiplier, descriptionLabelFont),
                        .paragraph([
                            .textAlignment(.left),
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(descriptionLabelLineHeightMultiplier)
                        ]),
                    ])
                    .appendAttributesToRange(
                        [
                            .foregroundColor: AppColors.Components.Link.primary.uiColor,
                            .font: descriptionLabelFont
                        ],
                        of: "pera-announcement-description-blog".localized
                    )
            ),
            .font(descriptionLabelFont),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(FittingText())
        ]

        horizontalPadding = 24
        bottomPadding = 16
        topContainerMaxHeight = 254
        topContainerMinHeight = 132
        firstTitleLabelTopPadding = 40
        secondTitleLabelTopPadding = 12
        descriptionLabelTopPadding = 20
        peraLogoMaxSize = (148, 64)
        peraLogoMinSize = (112, 48)
        closeButtonSize = (40, 40)
        closeButtonTopPadding = 10
        let buttonHeight = 52.0
        linearGradientHeight = bottomPadding + buttonHeight + UIApplication.shared.safeAreaBottom
    }
}
