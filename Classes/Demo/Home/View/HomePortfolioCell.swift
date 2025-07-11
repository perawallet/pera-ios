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

//
//   HomePortfolioCell.swift

import MacaroonUIKit
import UIKit

final class HomePortfolioCell:
    CollectionCell<HomePortfolioView>,
    ViewModelBindable,
    UIInteractable {
    
    // MARK: - Properties
    
    override class var contextPaddings: LayoutPaddings { (16, 24, 8, 24) }
    static let theme = HomePortfolioViewTheme()
    
    var isPrivacyModeTooltipVisible: Bool {
        get { contextView.isPrivacyModeTooltipVisible }
        set { contextView.isPrivacyModeTooltipVisible = newValue }
    }
    
    // MARK: - Initialisers
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        contentView.backgroundColor = Colors.Defaults.background.uiColor

        contextView.customize(Self.theme)
    }
}
