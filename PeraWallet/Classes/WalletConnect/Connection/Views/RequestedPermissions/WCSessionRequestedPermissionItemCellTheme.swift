// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionRequestedPermissionItemCellTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WCSessionRequestedPermissionItemCellTheme:
    StyleSheet,
    LayoutSheet {
    let context: WCSessionRequestedPermissionItemViewTheme
    let contextEdgeInsets: LayoutPaddings
    let separator: Separator

    init(_ family: LayoutFamily) {
        self.context = WCSessionRequestedPermissionItemViewTheme(family)
        self.contextEdgeInsets = (12, 0, 0, 0)
        self.separator = Separator(color: Colors.Layer.grayLighter)
    }
}

struct WCSessionRequestedPermissionItemViewTheme {
    let contentPaddings: LayoutPaddings
    let contentEdgeInsets: LayoutPaddings
    let content: ViewStyle
    let title: TextStyle
    let spacingBetweenTitleAndRows: LayoutMetric
    let row: TextStyle
    let rowIcon: ImageStyle
    let rowIconSize: LayoutSize
    let spacingBetweenRowIconAndTitle: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        self.content = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.contentPaddings = (0, 0, 0, 0)
        self.contentEdgeInsets = (16, 16, 16, 16)
        self.title = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.spacingBetweenTitleAndRows = 12
        self.row = [
            .textColor(Colors.Text.gray)
        ]
        self.rowIcon = [
            .image("icon-check")
        ]
        self.rowIconSize = (24, 24)
        self.spacingBetweenRowIconAndTitle = 9
    }
}
