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
//   TransactionResultScreen+Theme.swift


import Foundation
import MacaroonUIKit

extension TransactionResultScreen {
    struct Theme: LayoutSheet, StyleSheet {
        let backgroundColor: Color
        let titleLabel: TextStyle
        let subtitleLabel: TextStyle

        init(_ family: LayoutFamily) {
            backgroundColor = AppColors.Shared.System.background
            titleLabel = [
                .textColor(AppColors.Components.Text.main),
                .font(Fonts.DMSans.medium.make(19)),
                .textAlignment(.center),
                .textOverflow(SingleLineFittingText())
            ]
            subtitleLabel = [
                .textColor(AppColors.Components.Text.gray),
                .font(Fonts.DMSans.regular.make(15)),
                .textAlignment(.center),
                .textOverflow(SingleLineFittingText())
            ]
        }
    }
}
