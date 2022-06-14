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

//   HomeQuickActionsCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeQuickActionsCell:
    CollectionCell<HomeQuickActionsView>,
    UIInteractionObservable {
    override class var contextPaddings: LayoutPaddings {
        return (36, 24, 36, 24)
    }

    static let theme = HomeQuickActionsViewTheme()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        contentView.backgroundColor = AppColors.Shared.Helpers.heroBackground.uiColor
        contextView.customize(Self.theme)
    }
    
    class func calculatePreferredSize(
        for theme: HomeQuickActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let contextPaddings = Self.contextPaddings
        let contextWidth = size.width - contextPaddings.leading - contextPaddings.trailing
        let contextMaxSize = CGSize(width: contextWidth, height: .greatestFiniteMagnitude)
        let contextPreferredSize = ContextView.calculatePreferredSize(
            for: theme,
            fittingIn: contextMaxSize
        )
        let preferredHeight =
            contextPreferredSize.height +
            contextPaddings.top +
            contextPaddings.bottom
        return CGSize(width: size.width, height: min(preferredHeight, size.height))
    }
}
