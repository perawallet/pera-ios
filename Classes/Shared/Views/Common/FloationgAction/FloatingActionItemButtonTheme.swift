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
//   FloatingActionItemButtonTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct FloatingActionItemButtonTheme: StyleSheet, LayoutSheet {
    let container: ViewStyle
    let title: TextStyle
    let titleLabelTrailingPadding: LayoutMetric
    let titleShadow: MacaroonUIKit.Shadow
    let containerFirstShadow: MacaroonUIKit.Shadow
    let containerSecondShadow: MacaroonUIKit.Shadow

    init(_ family: LayoutFamily) {
        self.container = [
            .isInteractable(false),
            .backgroundColor(AppColors.Shared.Global.white),
        ]
        self.title = [
            .isInteractable(false),
            .textOverflow(SingleLineFittingText()),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Shared.Global.white)
        ]
        self.titleLabelTrailingPadding = 22

        // <todo> Apply same shadow with designs.
        self.titleShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.second.uiColor,
            opacity: 1,
            offset: (0, 1),
            radius: 3,
            fillColor: UIColor.clear
        )
        self.containerFirstShadow = MacaroonUIKit.Shadow(
            color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.16),
            opacity: 1,
            offset: (0, 28),
            radius: 32,
            fillColor: UIColor.clear
        )
        self.containerSecondShadow = MacaroonUIKit.Shadow(
            color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.16),
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: UIColor.clear
        )
    }
}
