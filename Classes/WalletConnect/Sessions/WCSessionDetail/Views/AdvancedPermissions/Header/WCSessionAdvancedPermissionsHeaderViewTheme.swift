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

//   WCSessionAdvancedPermissionsHeaderViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct WCSessionAdvancedPermissionsHeaderViewTheme:
    StyleSheet,
    LayoutSheet {
    let title: TextStyle
    let spacingBetweenTitleAndInfoAction: LayoutMetric
    let infoAction: ButtonStyle

    init(_ family: LayoutFamily) {
        self.title = [
            .textColor(Colors.Text.gray),
            .textOverflow(SingleLineText())
        ]
        self.spacingBetweenTitleAndInfoAction = 8
        self.infoAction = [
            .icon([ .normal("icon-info-20") ])
        ]
    }
}
