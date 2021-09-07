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
//   ChoosePasswordViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ChoosePasswordViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle

    let inputViewTopInset: LayoutMetric
    let passwordInputViewInset: LayoutMetric
    let numpadBottomInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.title = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .textAlignment(.left),
            .textOverflow(.fitting)
        ]

        self.horizontalInset = 24
        self.topInset = 12
        self.passwordInputViewInset = -10
        self.inputViewTopInset = 128 * verticalScale
        self.numpadBottomInset = 32 * verticalScale
    }
}
