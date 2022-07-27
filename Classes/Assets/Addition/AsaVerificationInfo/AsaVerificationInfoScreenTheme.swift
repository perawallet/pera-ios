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

//   VerificationInfoViewController+Theme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AsaVerificationInfoScreenTheme:
    LayoutSheet,
    StyleSheet {
    let illustration: ImageStyle
    let illustrationMaxHeight: LayoutMetric
    let illustrationMinHeight: LayoutMetric

    let closeAction: ButtonStyle
    let closeActionSize: LayoutSize
    let closeActionEdgeInsets: NSDirectionalEdgeInsets

    let title: TextStyle
    let titleEdgeInsets: NSDirectionalEdgeInsets

    let body: TextStyle
    let bodyEdgeInsets: NSDirectionalEdgeInsets

    let primaryAction: ButtonStyle
    let primaryActionContentEdgeInsets: UIEdgeInsets
    let primaryActionEdgeInsets: NSDirectionalEdgeInsets

    init(
        _ family: LayoutFamily
    ) {
        self.illustration = [
            .backgroundColor(AppColors.Shared.System.background),
            .image("verification-info-illustration"),
            .contentMode(.bottomLeft)
        ]
        self.illustrationMaxHeight = 204
        self.illustrationMinHeight = 68

        let closeActionIcon = "icon-close"
            .uiImage
            .withRenderingMode(.alwaysTemplate)
        self.closeAction = [
            .icon([.normal(closeActionIcon)]),
            .tintColor(AppColors.Components.Text.main)
        ]
        self.closeActionSize = (40, 40)
        self.closeActionEdgeInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 12,
            bottom: 0,
            trailing: 0
        )

        self.title = [
            .textColor(AppColors.Components.Text.main),
        ]
        self.titleEdgeInsets = NSDirectionalEdgeInsets(
            top: 40,
            leading: 24,
            bottom: 0,
            trailing: 24
        )

        self.body = [
            .textColor(AppColors.Components.Text.gray),
            .textOverflow(FittingText())
        ]
        self.bodyEdgeInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 24,
            bottom: 0,
            trailing: 24
        )

        self.primaryAction = [
            .title("title-learn-more".localized),
            .titleColor([
                .normal(AppColors.Components.Text.main)
            ]),
            .font(Fonts.DMSans.medium.make(15)),
            .backgroundImage([
                .normal("verification-info-action-background")
            ])
        ]
        self.primaryActionContentEdgeInsets = UIEdgeInsets(
            top: 14,
            left: 0,
            bottom: 14,
            right: 0
        )
        self.primaryActionEdgeInsets = NSDirectionalEdgeInsets(
            top: 36,
            leading: 24,
            bottom: 16,
            trailing: 24
        )
    }
}
