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

//   HomeQuickActionsCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeQuickActionsCell:
    CollectionCell<HomeQuickActionsView>,
    UIInteractable {
    override class var contextPaddings: LayoutPaddings {
        return (36, 24, 36, 24)
    }

    static let theme = HomeQuickActionsViewTheme()

    var isSwapBadgeVisible: Bool = false {
        didSet {
            contextView.isSwapBadgeVisible = isSwapBadgeVisible
        }
    }

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        contentView.backgroundColor = Colors.Defaults.background.uiColor

        contextView.customize(Self.theme)
    }

    class func calculatePreferredSize(
        for theme: HomeQuickActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let contextPaddings = Self.contextPaddings
        let contextWidth =
            width -
            contextPaddings.leading -
            contextPaddings.trailing
        let maxContextSize = CGSize((contextWidth, .greatestFiniteMagnitude))
        let contextSize = ContextView.calculatePreferredSize(
            for: theme,
            fittingIn: maxContextSize
        )
        let preferredHeight =
            contextPaddings.top +
            contextSize.height +
            contextPaddings.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}
