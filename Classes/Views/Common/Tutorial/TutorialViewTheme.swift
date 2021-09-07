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
//   TutorialViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct TutorialViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let description: TextStyle
    let warningImage: ImageStyle
    let warningTitle: TextStyle
    let mainButtonTheme: ButtonTheme
    let actionButtonTheme: ButtonTheme

    let titleTopInset: LayoutMetric
    let descriptionHorizontalInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let buttonInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let imagePaddings: LayoutPaddings
    let bottomInset: LayoutMetric
    let warningTitlePaddings: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.title = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .textAlignment(.left),
            .textOverflow(.fitting)
        ]
        self.description = [
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(.fitting)
        ]
        self.warningImage = [
            .image("icon-red-warning")
        ]
        self.warningTitle = [
            .textColor(AppColors.Shared.Helpers.negative),
            .font(Fonts.DMSans.medium.make(13)),
            .textAlignment(.left),
            .textOverflow(.fitting)
        ]
        self.mainButtonTheme = ButtonPrimaryTheme()
        self.actionButtonTheme = ButtonSecondaryTheme()

        self.titleTopInset = 24
        self.buttonInset = 16
        self.descriptionHorizontalInset = 24
        self.descriptionTopInset = 16
        self.horizontalInset = 24
        self.warningTitlePaddings = (0, 56, 32, 0)
        self.bottomInset = 16
        self.imagePaddings = (48, 12, 0, 0)
    }
}
