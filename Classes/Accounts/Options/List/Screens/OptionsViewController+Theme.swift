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
//   OptionsViewController+Theme.swift

import MacaroonUIKit
import UIKit

struct OptionsViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contentPaddings: LayoutPaddings
    var action: ListActionViewTheme

    init(
        _ family: LayoutFamily
) {
        self.background = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
        self.contentPaddings = (12, 24, 12, 24)
        self.action = ListActionViewTheme(family)
    }
}
