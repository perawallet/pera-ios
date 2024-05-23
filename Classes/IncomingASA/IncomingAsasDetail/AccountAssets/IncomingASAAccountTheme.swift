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

//   IncomingAsaAccountAssetsCellTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct IncomingASAAccountTheme:
    LayoutSheet,
    StyleSheet {
    
    let backgroundColor: Color
    let accountItem: AccountListItemViewTheme
    let divider: ViewStyle
    let assetItem: IncomingAsaListItemViewTheme
    let infoIconSize: LayoutSize
    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.black
        self.accountItem = AccountListItemViewTheme(family)
        self.divider = [
            .backgroundColor(Colors.Button.Helper.background)
        ]
        self.assetItem = IncomingAsaListItemTheme(family)
        self.infoIconSize = (24, 24)
        self.horizontalInset = 16
        self.verticalInset = 16
    }

}
