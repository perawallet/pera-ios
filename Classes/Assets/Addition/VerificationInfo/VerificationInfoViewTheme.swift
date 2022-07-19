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

//   VerificationInfoViewTheme.swift

import UIKit
import MacaroonUIKit

struct VerificationInfoViewTheme:
    StyleSheet,
    LayoutSheet {
    let backgroundColor: Color
    let horizontalPadding: LayoutMetric

    let title: TextStyle
    let titleTopPadding: LayoutMetric

    let description: TextStyle
    let descriptionTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.horizontalPadding = 24

        self.title = [
            .textColor(AppColors.Components.Text.main),
        ]
        self.titleTopPadding = 40

        self.description = [
            .textColor(AppColors.Components.Text.gray),
            .textOverflow(FittingText())
        ]
        self.descriptionTopPadding = 16
    }
}
