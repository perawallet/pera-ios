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

//   SendCollectibleBottomSheetViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SendCollectibleBottomSheetViewTheme:
    StyleSheet,
    LayoutSheet {
    let content: ViewStyle
    let contentCorner: Corner
    let handle: ImageStyle
    let handleTopPadding: LayoutMetric
    let closeActionViewPaddings: LayoutPaddings
    let closeAction: ButtonStyle
    let title: TextStyle
    let titleViewHorizontalPaddings: LayoutHorizontalPaddings
    let contextViewPaddings: LayoutPaddings
    let addressInputTheme: MultilineTextInputFieldViewTheme
    let selectReceiverAction: ButtonStyle
    let scanQRAction: ButtonStyle
    let actionButton: ButtonStyle
    let actionButtonContentEdgeInsets: LayoutPaddings
    let actionButtonCorner: Corner
    let actionButtonTopPadding: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        content = [
            .backgroundColor(AppColors.Shared.System.background)
        ]

        contentCorner = Corner(
            radius: 16,
            mask: [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        )

        closeActionViewPaddings = (30, 20, .noMetric, .noMetric)

        closeAction = [
            .icon([ .normal("icon-close") ])
        ]

        handle = [.image("icon-bottom-sheet-handle")]
        handleTopPadding = 8

        title = [
            .text(Self.getTitle("collectible-send-title".localized)),
            .textColor(AppColors.Components.Text.main),
            .textOverflow(SingleLineFittingText()),
        ]

        titleViewHorizontalPaddings = (8, 24)

        contextViewPaddings = (16, 24, 16, 24)

        let textInputBaseStyle: TextInputStyle = [
            .font(Fonts.DMSans.regular.make(15)),
            .tintColor(AppColors.Components.Text.main),
            .textColor(AppColors.Components.Text.main),
            .returnKeyType(.done)
        ]

        var addressInputTheme = MultilineTextInputFieldViewCommonTheme(
            textInput: textInputBaseStyle,
            placeholder:"collectible-send-input-placeholder".localized,
            floatingPlaceholder: "collectible-send-input-placeholder".localized
        )

        addressInputTheme.configureForDoubleAccessory()
        self.addressInputTheme = addressInputTheme

        selectReceiverAction = [
            .icon([ .normal("icon-settings-contacts") ])
        ]

        scanQRAction = [
            .icon([ .normal("icon-qr-scan") ])
        ]

        actionButton = [
            .title(Self.getTitle("collectible-send-action".localized)),
            .titleColor([ .normal(AppColors.Components.Button.Primary.text) ]),
            .backgroundColor(AppColors.Components.Button.Primary.background)
        ]
        actionButtonContentEdgeInsets = (14, 0, 14, 0)
        actionButtonCorner = Corner(radius: 4)
        actionButtonTopPadding = 32
    }
}

extension SendCollectibleBottomSheetViewTheme {
    private static func getTitle(
        _ title: String
    ) -> EditText {
        let font = Fonts.DMSans.medium.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            title
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }
}
