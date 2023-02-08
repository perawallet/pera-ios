// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupSuccessScreenTheme.swift

import Foundation
import MacaroonUIKit

struct AlgorandSecureBackupSuccessScreenTheme:
    LayoutSheet,
    StyleSheet {
    var background: ViewStyle
    var contextPaddings: LayoutPaddings
    var header: ResultViewTheme
    var spacingBetweenHeaderAndFileContent: LayoutMetric
    var fileContentFirstShadow: MacaroonUIKit.Shadow
    var fileContentSecondShadow: MacaroonUIKit.Shadow
    var fileContentThirdShadow: MacaroonUIKit.Shadow
    var fileContentPaddings: LayoutPaddings
    var fileIcon: ImageStyle
    var spacingBetweenFileIconAndFileInfoContent: LayoutMetric
    var fileInfoName: TextStyle
    var spacingBetweenFileInfoNameAndFileInfoSize: LayoutMetric
    var fileInfoSize: TextStyle
    var spacingBetweenFileInfoContentAndFileCopyAccessory: LayoutMetric
    var fileCopyAccessory: ButtonStyle
    var saveAction: ButtonStyle
    var saveActionLayout: Button.Layout
    var doneAction: ButtonStyle
    var actionEdgeInsets: LayoutPaddings
    var actionMargins: LayoutMargins
    var spacingBetweenActions: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contextPaddings = (28, 24, 24, 24)
        self.header = AlgorandSecureBackupSuccessHeaderViewTheme(family)
        self.spacingBetweenHeaderAndFileContent = 28
        self.fileContentFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.fileContentSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.fileContentThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (20, 20),
            corners: .allCorners
        )
        self.fileContentPaddings = (20, 20, 20, 20)
        self.fileIcon = [ .image("icon-txt-file") ]
        self.spacingBetweenFileIconAndFileInfoContent = 16
        self.fileInfoName = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText()),
        ]
        self.spacingBetweenFileInfoNameAndFileInfoSize = 4
        self.fileInfoSize = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText()),
        ]
        self.spacingBetweenFileInfoContentAndFileCopyAccessory = 16
        self.fileCopyAccessory = [
            .backgroundImage([ .normal("icon-copy-circle"), .highlighted("icon-copy-circle")])
        ]
        self.saveAction = [
            .title("algorand-secure-backup-success-save-action-title".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Primary.text)
            ]),
            .icon([ .normal("icon-download"), .highlighted("icon-download") ]),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted")
            ])
        ]
        self.saveActionLayout = .imageAtLeft(spacing: 12)
        self.doneAction = [
            .title("title-done".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Secondary.text)
            ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted")
            ])
        ]
        self.actionEdgeInsets = (16, 8, 16, 8)
        self.actionMargins = (12, 24, 12, 24)
        self.spacingBetweenActions = 16
    }
}
