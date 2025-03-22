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

//   SelectAddressListItemTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SelectAddressListItemTheme:
    StyleSheet,
    LayoutSheet {
    var contextEdgeInsets: LayoutPaddings
    var titleTheme: SelectAddressListItemTitleViewTheme
    var currencyTheme: SelectAddressListItemCurrencyViewTheme
    var spacingBetweenContextAndAccessory: LayoutMetric
    var accessorySize: LayoutSize
    var selectedAccessory: ImageStyle
    var unselectedAccessory: ImageStyle
    var separator: Separator

    init(_ family: LayoutFamily) {
        self.contextEdgeInsets = (14, 0, 14, 0)
        self.titleTheme = SelectAddressListItemTitleViewTheme(family)
        self.currencyTheme = SelectAddressListItemCurrencyViewTheme(family)
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

    subscript (accessory: SelectAddressListItemAccessory) -> ImageStyle {
        switch accessory {
        case .selected: return selectedAccessory
        case .unselected: return unselectedAccessory
        case .none: return []
        }
    }
}

struct SelectAddressListItemTitleViewTheme: StyleSheet, LayoutSheet {
    var title: TextStyle

    init(_ family: LayoutFamily) {
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyRegular())
        ]
    }
}

struct SelectAddressListItemCurrencyViewTheme: StyleSheet, LayoutSheet {
    var main: TextStyle
    var secondary: TextStyle

    init(_ family: LayoutFamily) {
        self.main = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyMedium())
        ]
        self.secondary = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.sonicSilver),
            .font(Typography.footnoteRegular())
        ]
    }
}
