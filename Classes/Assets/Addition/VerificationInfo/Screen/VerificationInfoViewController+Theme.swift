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

//   VerificationInfoViewController+Theme.swift

import Foundation
import MacaroonUIKit

extension VerificationInfoViewController {
    struct Theme: LayoutSheet, StyleSheet {
        let scrollViewTopInset: LayoutMetric
        
        let header: VerificationInfoHeaderViewTheme
        let headerMaxHeight: LayoutMetric
        let headerMinHeight: LayoutMetric
        
        let context: VerificationInfoViewTheme

        let button: ButtonStyle
        let buttonContentInsets: LayoutPaddings
        let buttonCorner: Corner
        let buttonTopPadding: LayoutMetric
        let buttonHorizontalPadding: LayoutMetric
        let buttonBottomPadding: LayoutMetric

        init(_ family: LayoutFamily) {
            self.scrollViewTopInset = 204

            self.header = VerificationInfoHeaderViewTheme()
            self.headerMaxHeight = 204
            self.headerMinHeight = 68

            self.context = VerificationInfoViewTheme()

            self.button = [
                .title("title-learn-more".localized),
                .titleColor([
                    .normal(AppColors.Components.Text.main)
                ]),
                .font(Fonts.DMSans.medium.make(15)),
                .backgroundColor(AppColors.Components.Button.Secondary.background)
            ]
            self.buttonContentInsets = (14, 0, 14, 0)
            self.buttonCorner = Corner(radius: 4)
            self.buttonTopPadding = 36
            self.buttonHorizontalPadding = 24
            self.buttonBottomPadding = 16
        }
    }
}
