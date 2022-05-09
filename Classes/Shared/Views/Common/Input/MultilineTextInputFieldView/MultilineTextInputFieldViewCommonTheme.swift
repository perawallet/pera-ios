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

//
//   MultilineTextInputFieldViewCommonTheme.swift

import Foundation
import MacaroonUIKit

struct MultilineTextInputFieldViewCommonTheme: MultilineTextInputFieldViewTheme {
    let textInput: TextInputStyle
    let textInputMinHeight: LayoutMetric
    var textContainerInsets: LayoutPaddings
    let placeholder: TextStyle
    let floatingPlaceholder: TextStyle
    let topInset: LayoutMetric
    let focusIndicator: ViewStyle
    let focusIndicatorTopInset: LayoutMetric
    let focusIndicatorActive: ViewStyle
    let errorFocusIndicator: ViewStyle
    let assistive: FormInputFieldAssistiveViewTheme
    
    init(
        textInput: TextInputStyle,
        placeholder: String,
        floatingPlaceholder: String? = nil,
        _ family: LayoutFamily = .current
    ) {
        self.textInput = textInput
        self.textInputMinHeight = 48
        self.textContainerInsets = (24, 0, 0, 65)
        self.placeholder = [
            .font(Fonts.DMSans.regular.make(15, .body)),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .text(placeholder)
        ]
        self.floatingPlaceholder = [
            .textColor(AppColors.Components.Text.grayLighter),
            .text((floatingPlaceholder ?? placeholder).body(hasMultilines: false))
        ]
        self.topInset = 24.0
        self.focusIndicator = [
            .backgroundColor(AppColors.Components.TextField.indicatorDeactive)
        ]
        self.focusIndicatorTopInset = 3
        self.focusIndicatorActive = [
            .backgroundColor(AppColors.Components.TextField.indicatorActive)
        ]
        self.errorFocusIndicator = [
            .backgroundColor(AppColors.Shared.Helpers.negative)
        ]
        self.assistive = FormInputFieldAssistiveViewCommonTheme()
    }
    
    init(_ family: LayoutFamily) {
        self.init(
            textInput: [],
            placeholder: "",
            family
        )
    }
}

extension MultilineTextInputFieldViewCommonTheme {
    mutating func configureForDoubleAccessory() {
        textContainerInsets.trailing = 105
    }
}
