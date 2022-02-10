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
//   TransactionHistoryTitleContextViewTheme.swift

import MacaroonUIKit

struct TransactionHistoryTitleContextViewTheme: StyleSheet, LayoutSheet {
    let titleLabel: TextStyle
    let paddings: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.titleLabel = [
            .textAlignment(.left),
            .textOverflow(SingleLineFittingText()),
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(13)),
        ]
        self.paddings = (28, 24, 4, 24)
    }
}
