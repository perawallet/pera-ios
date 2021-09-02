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
//   ScreenShotWarningViewTheme.swift

import Foundation
import Macaroon
import UIKit

struct ScreenShotWarningViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let description: TextStyle
    let image: ImageStyle

    let closeButtonTheme: ButtonTheme

    let verticalInset: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let descriptionTopInset: LayoutMetric
    let imageSize: LayoutSize
    let titleTopInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Background.secondary
        self.title = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(19)),
            .textAlignment(.center),
            .textOverflow(.fitting),
            .content("screenshot-title".localized)
        ]
        self.description = [
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.center),
            .textOverflow(.fitting),
            .content("screenshot-description".localized)
        ]
        self.image = [
            .content(img("icon-info-red"))
        ]

        self.closeButtonTheme = ButtonSecondaryTheme()

        self.verticalInset = 32
        self.horizontalInset = 20
        self.topInset = 42
        self.titleTopInset = 28
        self.descriptionTopInset = 12
        self.imageSize = (80, 80)
    }
}
