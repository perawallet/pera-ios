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

//   SecondaryListItemValueViewTheme.swift

import MacaroonUIKit

protocol SecondaryListItemValueViewTheme:
    LayoutSheet,
    StyleSheet {
    /// <note> If view has action, pass `true` to `isInteractable(Bool)` attribute.
    var view: ViewStyle { get }
    var corner: Corner { get }
    var contentEdgeInsets: LayoutPaddings { get }
    var icon: ImageStyle { get }
    var iconLayoutOffset: LayoutOffset { get }
    var title: TextStyle { get }
}

extension SecondaryListItemValueViewTheme {
    var supportsMultiline: Bool {
        let numberOfLines = title.textOverflow?.numberOfLines ?? 1
        return numberOfLines > 1 || numberOfLines == 0
    }
}

struct SecondaryListItemValueCommonViewTheme: SecondaryListItemValueViewTheme {
    var view: ViewStyle
    var corner: Corner
    var contentEdgeInsets: LayoutPaddings
    var icon: ImageStyle
    var iconLayoutOffset: LayoutOffset
    var title: TextStyle

    init(
        _ family: LayoutFamily = .current,
        isMultiline: Bool
    ) {
        view = [ .isInteractable(false) ]
        corner = Corner(
            radius: .zero
        )
        contentEdgeInsets = (0, 0, 0, 0)
        icon = [
            .contentMode(.left),
        ]
        iconLayoutOffset = (10, 0)

        if isMultiline {
            title = [ .textOverflow(MultilineText(numberOfLines: 2)) ]
        } else {
            title = []
        }
    }

    init(
        _ family: LayoutFamily
    ) {
        self.init(
            family,
            isMultiline: false
        )
    }
}
