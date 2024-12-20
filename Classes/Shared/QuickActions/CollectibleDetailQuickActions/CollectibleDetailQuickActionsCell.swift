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

//   CollectibleDetailQuickActionsCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleDetailQuickActionsCell:
    CollectionCell<CollectibleDetailQuickActionsView>,
    UIInteractable {
    override class var contextPaddings: LayoutPaddings {
        return (10, 24, 10, 24)
    }

    static let theme = CollectibleDetailQuickActionsViewTheme()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        contentView.backgroundColor = Colors.Defaults.background.uiColor

        contextView.customize(Self.theme)
    }

    class func calculatePreferredSize(
        for theme: CollectibleDetailQuickActionsViewTheme,
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
