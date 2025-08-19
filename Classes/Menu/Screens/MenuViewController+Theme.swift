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

//   MenuViewController+Theme.swift

import MacaroonUIKit
import UIKit

extension MenuViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let cellHeight: LayoutMetric
        let cardsCellHeight: LayoutMetric
        let listItemTheme: MenuListViewTheme
        
        init(_ family: LayoutFamily) {
            self.cellHeight = 72.0
            self.cardsCellHeight = 220.0
            self.listItemTheme = MenuListViewTheme(family)
        }
    }
}

struct MenuListViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let cellSpacing: LayoutMetric
    let collectionViewEdgeInsets: LayoutPaddings
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.cellSpacing = 12
        self.collectionViewEdgeInsets = (36, 16, 0, 16)
    }
}
