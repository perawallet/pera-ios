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
//   AccountNameSetupViewTheme.swift

import Foundation
import Macaroon
import UIKit

struct AccountNameSetupViewTheme: StyleSheet, LayoutSheet {
    let title: TextStyle
    let description: TextStyle

    let mainButtonTheme: ButtonTheme

    let textInputVerticalInset: LayoutMetric
    let buttonVerticalInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let bottomInset: LayoutMetric
    let topInset: LayoutMetric
    let containerTopInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.title = [
            .textAlignment(.left),
            .textOverflow(.fitting),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .content("account-details-title".localized)
        ]

        self.description = [
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(.fitting),
            .content("account-name-setup-description".localized)
        ]

        self.mainButtonTheme = ButtonPrimaryTheme()

        self.textInputVerticalInset = 40
        self.buttonVerticalInset = 60
        self.horizontalInset = 20
        self.bottomInset = 16
        self.topInset = 12
        self.containerTopInset = 32
    }
}
