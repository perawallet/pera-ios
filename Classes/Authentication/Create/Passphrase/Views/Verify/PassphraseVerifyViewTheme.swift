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
//   PassphraseVerifyViewTheme.swift

import MacaroonUIKit
import UIKit

struct PassphraseVerifyViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    
    let title: TextStyle
    let titleText: EditText
    
    let cardViewBottomOffset: LayoutMetric

    let nextButtonTheme: ButtonTheme

    let titleTopInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let buttonVerticalInset: LayoutMetric
    let buttonTopOffset: LayoutMetric
    let listTopOffset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
        ]
        let titleFont = Fonts.DMSans.medium.make(32)
        let titleLineHeightMultiplier = 0.96
        self.titleText = .attributedString(
            "passphrase-verify-title"
                .localized
                .attributed([
                    .font(titleFont),
                    .lineHeightMultiplier(titleLineHeightMultiplier, titleFont),
                    .paragraph([
                        .lineHeightMultiple(titleLineHeightMultiplier)
                    ]),
                    .textColor(AppColors.Components.Text.main),
                    .letterSpacing(-0.32)
                ])
        )
        
        self.cardViewBottomOffset = 32
        
        self.nextButtonTheme = ButtonPrimaryTheme()

        self.titleTopInset = 2
        self.horizontalInset = 24
        self.buttonVerticalInset = 16
        self.buttonTopOffset = 24
        self.listTopOffset = 40
    }
}
