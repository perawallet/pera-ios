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

//   ExportAccountsResultViewTheme.swift

import Foundation
import MacaroonUIKit

struct ExportAccountsResultViewTheme: ResultViewTheme {
    let icon: ImageStyle
    let iconLeadingMargin: LayoutMetric
    let title: TextStyle
    var titleTopMargin: MacaroonUIKit.LayoutMetric
    var bodyTopMargin: MacaroonUIKit.LayoutMetric
    let body: TextStyle

    init(
        _ family: LayoutFamily
    ) {
        self.icon = [
            .adjustsImageForContentSizeCategory(false),
            .contentMode(.left)
        ]
        self.iconLeadingMargin = 10
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main)
        ]
        self.titleTopMargin = 40
        self.body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray)
        ]
        self.bodyTopMargin = 22
    }
}
