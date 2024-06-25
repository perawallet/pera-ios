// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASAAccountViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct IncomingASAAccountViewTheme:
    StyleSheet,
    LayoutSheet {
    let icon: ImageStyle
    let iconSize: LayoutSize
    let horizontalPadding: LayoutMetric
    let contentMinWidthRatio: LayoutMetric
    let title: TextStyle
    let primaryAccessory: TextStyle
    let accessoryIconContentEdgeInsets: LayoutOffset

    init(_ family: LayoutFamily) {
        self.icon = [
            .contentMode(.scaleAspectFit)
        ]
        self.iconSize = (40, 40)
        self.horizontalPadding = 16
        self.contentMinWidthRatio = 0.25
        self.title = [
            .textColor(Colors.Text.main),
            .font(Typography.bodyMedium()),
            .textOverflow(MultilineText(numberOfLines: 0))
        ]
        self.primaryAccessory = [
            .textColor(Colors.Text.gray),
            .font(Typography.footnoteRegular()),
            .textOverflow(MultilineText(numberOfLines: 0)),
            .textAlignment(.right)
        ]
        self.accessoryIconContentEdgeInsets = (8, 0)
    }
}
