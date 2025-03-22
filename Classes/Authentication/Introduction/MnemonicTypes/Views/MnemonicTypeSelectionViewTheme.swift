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

//   MnemonicTypeSelectionViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

struct MnemonicTypeSelectionViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let bip39ViewTheme: MnemonicTypeViewTheme
    let algo25ViewTheme: MnemonicTypeViewTheme
    
    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.bip39ViewTheme = MnemonicTypeViewTheme(family)
        self.algo25ViewTheme = MnemonicTypeViewTheme(family)

        self.horizontalInset = 24
        self.verticalInset = 20
    }
}
