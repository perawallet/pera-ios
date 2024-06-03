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
    let accountItem: AccountListItemViewTheme
    let accountTopInset: LayoutMetric
    let accountAssetViewTopInset: LayoutMetric
    let divider: ViewStyle
    let dividerLeadingInset: LayoutMetric
    let dividerTopInset: LayoutMetric
    let dividerHeight: LayoutMetric
    let assetItem: IncomingASAListItemViewTheme
    let infoIconSize: LayoutSize
    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.height = 200
        self.backgroundColor = Colors.Defaults.black
        var theme = AccountListItemViewTheme()
        theme.forceToDark()
        self.accountItem = theme
        self.accountTopInset = 16
        self.accountAssetViewTopInset = 64
        self.divider = [
            .backgroundColor(Colors.Button.Helper.background)
        ]
        self.dividerLeadingInset = 48
        self.dividerTopInset = 20
        self.dividerHeight = 1
        self.assetItem = IncomingASADetailHeaderAssetTheme()
        self.infoIconSize = (24, 24)
        self.horizontalInset = 16
        self.verticalInset = 16
    }
}
