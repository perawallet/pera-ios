// Copyright 2022-2025 Pera Wallet, LDA

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
//   ContactDetailViewTheme.swift

import MacaroonUIKit

struct ContactDetailViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let assetsTitle: TextStyle

    let userInformationViewTopPadding: LayoutMetric
    let assetsLabelTopPadding: LayoutMetric
    let horizontalPadding: LayoutMetric
    let collectionViewTopPadding: LayoutMetric
    let bottomPadding: LayoutMetric
    let cellSpacing: LayoutMetric
    let contactInformationViewTheme: ContactInformationViewTheme

    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.background
        self.assetsTitle = [
            .textOverflow(FittingText()),
            .textAlignment(.left),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(Colors.Text.main),
            .text(String(localized: "title-assets"))
        ]
        self.contactInformationViewTheme = ContactInformationViewTheme()

        self.assetsLabelTopPadding = 39
        self.userInformationViewTopPadding = 32
        self.horizontalPadding = 24
        self.collectionViewTopPadding = 8
        self.bottomPadding = 16
        self.cellSpacing = 0
    }
}
