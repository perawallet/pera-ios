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
//   AccountTypeViewTheme.swift

import MacaroonUIKit
import Foundation
import UIKit

struct AccountTypeViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let detail: TextStyle

    let iconSize: LayoutSize
    let horizontalInset: LayoutMetric
    let verticalInset: LayoutMetric
    let minimumInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.title = [
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Components.Text.main),
            .textAlignment(.left),
            .isInteractable(false)
        ]
        self.detail = [
            .textOverflow(FittingText()),
            .font(Fonts.DMSans.regular.make(13)),
            .textColor(AppColors.Components.Text.gray),
            .textAlignment(.left),
            .isInteractable(false)
        ]

        self.iconSize = (40, 40)
        self.horizontalInset = 24
        self.verticalInset = 24
        self.minimumInset = 2
    }
}
