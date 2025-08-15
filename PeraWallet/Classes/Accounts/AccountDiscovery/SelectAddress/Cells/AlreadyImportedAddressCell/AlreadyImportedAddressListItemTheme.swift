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

//   AlreadyImportedAddressListItemTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AlreadyImportedAddressListItemTheme:
    StyleSheet,
    LayoutSheet {
    var contextEdgeInsets: LayoutPaddings
    var titleTheme: AlreadyImportedAddressListItemTitleViewTheme
    var textTheme: AlreadyImportedAddressListItemTextViewTheme
    var separator: Separator

    init(_ family: LayoutFamily) {
        self.contextEdgeInsets = (14, 0, 14, 0)
        self.titleTheme = AlreadyImportedAddressListItemTitleViewTheme(family)
        self.textTheme = AlreadyImportedAddressListItemTextViewTheme(family)
        self.separator = Separator(
            color: Colors.Layer.grayLighter,
            position: .bottom((0, 0))
        )
    }
}

struct AlreadyImportedAddressListItemTitleViewTheme: StyleSheet, LayoutSheet {
    var title: TextStyle
    let spacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.title = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyRegular())
        ]
        self.spacing = 16
    }
}

struct AlreadyImportedAddressListItemTextViewTheme: StyleSheet, LayoutSheet {
    var text: TextStyle
    let spacing: LayoutMetric

    init(_ family: LayoutFamily) {
        self.text = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.sonicSilver),
            .font(Typography.captionMedium()),
            .textAlignment(.center),
            .text(String(localized: "already-imported-title").uppercased()),
            .backgroundColor(Colors.Button.Secondary.background)
        ]
        self.spacing = 16
    }
}
