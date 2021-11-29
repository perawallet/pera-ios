// Copyright 2019 Algorand, Inc.

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
//   SearchInputViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct SearchInputViewTheme: LayoutSheet, StyleSheet {
    let textInput: TextInputStyle
    let textInputBackground: ViewStyle
    let textLeftInputAccessory: ImageStyle
    let textRightInputAccessory: ButtonStyle

    let intrinsicHeight: LayoutMetric
    let textInputContentEdgeInsets: LayoutPaddings
    let textInputPaddings: LayoutPaddings
    let textInputAccessorySize: LayoutSize
    let textRightInputAccessoryViewPaddings: LayoutPaddings
    
    private let placeholder: String

    init(placeholder: String, family: LayoutFamily) {
        self.placeholder = placeholder

        self.textInput = [
            .tintColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(AppColors.Components.Text.main),
            .placeholder(placeholder),
            .placeholderColor(AppColors.Components.Text.gray),
            .returnKeyType(.done)
        ]
        self.textInputBackground = [
            .backgroundColor(AppColors.Shared.Layer.grayLighter)
        ]
        self.textLeftInputAccessory = [
            .image("icon-field-search")
        ]
        self.textRightInputAccessory = [
            .icon([.normal("icon-field-close")])
        ]

        self.intrinsicHeight = 40
        self.textInputContentEdgeInsets = (0, 12, 0, 36)
        self.textInputPaddings = (0, 0, 0, 0)
        self.textInputAccessorySize = (24, 24)
        self.textRightInputAccessoryViewPaddings = (0, .noMetric, 0, 12)
    }

    init(_ family: LayoutFamily) {
        self.init(placeholder: .empty, family: family)
    }
}
