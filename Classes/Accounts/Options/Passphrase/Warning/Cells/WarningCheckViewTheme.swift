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

//   WarningCheckViewTheme.swift

import MacaroonUIKit
import UIKit

struct WarningCheckViewTheme:
    StyleSheet,
    LayoutSheet {
    var contextEdgeInsets: LayoutPaddings
    var title: TextStyle
    var spacingBetweenContextAndAccessory: LayoutMetric
    var accessorySize: LayoutSize
    var selectedAccessory: ImageStyle
    var unselectedAccessory: ImageStyle
    var separator: Separator

    init(_ family: LayoutFamily) {
        self.contextEdgeInsets = (14, 0, 14, 0)
        self.title = [
            .textOverflow(MultilineText(numberOfLines: 0)),
            .textColor(Colors.Text.main),
            .font(Typography.footnoteRegular())
        ]
        self.spacingBetweenContextAndAccessory = 20
        self.accessorySize = (24, 24)
        self.selectedAccessory = [
            .image("icon-checkbox-selected")
        ]
        self.unselectedAccessory = [
            .image("icon-checkbox-unselected")
        ]
        self.separator = Separator(
            color: Colors.Layer.grayLighter,
            position: .bottom((0, 0))
        )
    }

    subscript (accessory: WarningCheckViewAccessory) -> ImageStyle {
        switch accessory {
        case .selected: selectedAccessory
        case .unselected: unselectedAccessory
        case .none: []
        }
    }
}
