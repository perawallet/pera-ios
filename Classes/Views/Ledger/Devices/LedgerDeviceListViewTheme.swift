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
//   LedgerDeviceListViewTheme.swift

import Foundation
import Macaroon
import UIKit

struct LedgerDeviceListViewTheme: StyleSheet, LayoutSheet {
    let title: TextStyle
    let description: TextStyle
    let backgroundColor: Color
    let indicator: ImageStyle

    let lottie: String

    let collectionViewMinimumLineSpacing: LayoutMetric
    let verticalStackViewTopPadding: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let listContentInset: LayoutPaddings
    let titleLabelTopPadding: LayoutMetric
    let devicesListTopPadding: LayoutMetric
    let indicatorViewTopPadding: LayoutMetric
    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.title = [
            .textAlignment(.center),
            .textOverflow(.fitting),
            .font(Fonts.DMSans.medium.make(19)),
            .textColor(AppColors.Components.Text.main),
            .content("ledger-device-list-looking".localized)
        ]
        self.description = [
            .textAlignment(.center),
            .textOverflow(.fitting),
            .font(Fonts.DMSans.regular.make(15)),
            .textColor(AppColors.Components.Text.gray),
            .content("tutorial-description-ledger".localized)
        ]
        self.indicator = [
            .content(img("loading-indicator")),
            .contentMode(.scaleAspectFill)
        ]

        self.lottie = UIApplication.shared.isDarkModeDisplay ? "dark-ledger" : "light-ledger" /// <note>:  Should be handled also on view.

        self.collectionViewMinimumLineSpacing = 20
        self.verticalStackViewTopPadding = 66
        self.verticalStackViewSpacing = 12
        self.listContentInset = (10, 0, 0, 0)
        self.titleLabelTopPadding = 30
        self.devicesListTopPadding = 50
        self.indicatorViewTopPadding = 60
        self.horizontalInset = 20
    }
}
