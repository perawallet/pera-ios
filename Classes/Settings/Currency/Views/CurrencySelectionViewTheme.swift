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

//   CurrencySelectionViewTheme.swift

import Foundation
import MacaroonUIKit

struct CurrencySelectionViewTheme:
    StyleSheet,
    LayoutSheet {
    let backgroundColor: Color
    let horizontalPadding: LayoutMetric
    
    let searchInputViewTheme: SearchInputViewTheme
    let searchViewTopPadding: LayoutMetric
    
    let collectionViewEdgeInsets: LayoutPaddings
    let collectionViewTopPadding: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.horizontalPadding = 24
        
        self.searchInputViewTheme = SearchInputViewCommonTheme(
            placeholder: "settings-currency-search".localized,
            family: family
        )
        self.searchViewTopPadding = 20
        
        self.collectionViewEdgeInsets = (16, 0, 0, 0)
        self.collectionViewTopPadding = 12
    }
}
