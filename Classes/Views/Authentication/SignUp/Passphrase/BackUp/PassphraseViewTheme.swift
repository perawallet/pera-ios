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
//   PassphraseViewTheme.swift

import Foundation
import Macaroon
import UIKit

struct PassphraseViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let description: TextStyle
    let passphraseContainerView: ViewStyle
    let passphraseContainerCorner: Corner
    
    let mainButtonTheme: ButtonTheme

    let titleHorizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let containerTopInset: LayoutMetric
    let collectionViewHeight: LayoutMetric
    let verticalInset: LayoutMetric
    let bottomInset: LayoutMetric
    let collectionViewHorizontalInset: LayoutMetric
    let horizontalInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.title = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(32)),
            .textAlignment(.left),
            .textOverflow(.fitting),
            .content("recover-passphrase-title".localized)
        ]
        self.description = [
            .textColor(AppColors.Components.Text.gray),
            .font(Fonts.DMSans.regular.make(15)),
            .textAlignment(.left),
            .textOverflow(.fitting),
            .content("passphrase-bottom-title".localized)
        ]
        self.passphraseContainerView = [
            .backgroundColor(AppColors.Shared.Layer.grayLightest)
        ]
        self.passphraseContainerCorner = Corner(radius: 12)
 
        self.mainButtonTheme = ButtonPrimaryTheme()

        self.titleHorizontalInset = 24
        self.topInset = 12
        self.containerTopInset = 32
        self.collectionViewHeight = 448
        self.verticalInset = 20
        self.bottomInset = 16
        self.collectionViewHorizontalInset = 20 * horizontalScale
        self.horizontalInset = 20
    }
}
