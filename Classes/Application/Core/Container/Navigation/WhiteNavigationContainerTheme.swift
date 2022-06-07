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

//   WhiteNavigationContainerTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WhiteNavigationContainerTheme: NavigationContainerTheme {
    let navigationStyle: NavigationBarStyle
    let viewStyle: ViewStyle

    init(_ family: LayoutFamily) {
        let titleAttributeGroup: TextAttributeGroup = [
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Components.Text.main)
        ]
        let largeTitleAttributeGroup: TextAttributeGroup = [
            .font(Fonts.DMSans.medium.make(32)),
            .textColor(AppColors.Components.Text.main)
        ]

        navigationStyle = [
            .backgroundColor(AppColors.Shared.System.background),
            .backImage("icon-back"),
            .isOpaque(true),
            .largeTitleAttributes(largeTitleAttributeGroup.asSystemAttributes()),
            .shadowImage(UIImage()),
            .shadowColor(nil),
            .tintColor(AppColors.Components.Text.main),
            .titleAttributes(titleAttributeGroup.asSystemAttributes())
        ]

        viewStyle = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
    }
}
