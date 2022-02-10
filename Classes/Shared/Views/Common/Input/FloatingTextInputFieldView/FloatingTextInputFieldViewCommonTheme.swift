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
//   FloatingTextInputFieldViewCommonTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct FloatingTextInputFieldViewCommonTheme: FloatingTextInputFieldViewTheme {
    let textInput: TextInputStyle
    let textInputMinHeight: LayoutMetric
    let textInputMask: TextInputStyle
    let placeholder: TextStyle
    let floatingPlaceholder: TextStyle
    let focusIndicator: ViewStyle
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
        self.textInputMask = []
        self.placeholder = [
            .font(Fonts.DMSans.regular.make(15, .body)),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.grayLighter),
            .text(placeholder)
        ]
        self.floatingPlaceholder = [
            .textColor(AppColors.Components.Text.grayLighter),
            .text(
                (floatingPlaceholder ?? placeholder).body(hasMultilines: false)
            )
        ]
        self.focusIndicator = [
            .backgroundColor(AppColors.Components.TextField.indicatorDeactive)
        ]
        self.focusIndicatorActive = [
            .backgroundColor(AppColors.Components.TextField.indicatorActive)
        ]
        self.errorFocusIndicator = [
            .backgroundColor(AppColors.Shared.Helpers.negative)
        ]
        self.assistive = FormInputFieldAssistiveViewCommonTheme()
    }

    init(
        _ family: LayoutFamily
    ) {
        self.init(
            textInput: [],
            placeholder: "",
            family
        )
    }
}

extension String {
    func body(
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        hasMultilines: Bool = true
    ) -> NSAttributedString {
        return attributed(
            [
                .font(Fonts.DMSans.regular.make(13, .body).uiFont),
                .letterSpacing(0.4),
                .paragraph(
                    [
                        .alignment(alignment),
                        .lineBreakMode(lineBreakMode),
                        .lineHeightMultiple(hasMultilines ? 0.67 : 0)
                    ]
                )
            ]
        )
    }
}
