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
//   AccountListViewTheme.swift

import MacaroonUIKit

struct AccountListViewTheme: LayoutSheet, StyleSheet {
    let titleLabel: TextStyle
    let backgroundColor: Color
    let cellSpacing: LayoutMetric
    let verticalPadding: LayoutMetric
    let accountListBottomInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.titleLabel = [
            .textAlignment(.center),
            .textOverflow(.fitting),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(15))
        ]
        self.backgroundColor = AppColors.Shared.System.background
        self.cellSpacing = 0
        self.verticalPadding = 22
        self.accountListBottomInset = -20.0
    }
}
