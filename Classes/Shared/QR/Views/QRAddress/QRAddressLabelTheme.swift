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
//   QRAddressLabelTheme.swift

import Foundation
import MacaroonUIKit

struct QRAddressLabelTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let title: TextStyle
    let address: TextStyle
    
    let spacing: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.title = [
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText(lineBreakMode: .byTruncatingMiddle)),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(19))
        ]
        self.address = [
            .textAlignment(.center),
            .textOverflow(FittingText()),
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.regular.make(15))
        ]

        self.spacing = 12
    }
}
