// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ASADetailPageContainerHeaderTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASADetailPageContainerHeaderTheme:
    StyleSheet,
    LayoutSheet {
    var activityButton: ButtonStyle
    var aboutButton: ButtonStyle
    var activityButtonSelected: ButtonStyle
    var aboutButtonSelected: ButtonStyle

    init(_ family: LayoutFamily) {
        self.activityButton = [
            .title(String(localized: "title-activity")),
            .font(Typography.bodyRegular()),
            .titleColor([.normal(Colors.Text.main)])
        ]
        self.aboutButton = [
            .title(String(localized: "title-about")),
            .font(Typography.bodyRegular()),
            .titleColor([.normal(Colors.Text.main)])
        ]
        self.activityButtonSelected = [
            .title(String(localized: "title-activity")),
            .font(Typography.bodyMedium()),
            .titleColor([.normal(Colors.Text.main)])
        ]
        self.aboutButtonSelected = [
            .title(String(localized: "title-about")),
            .font(Typography.bodyMedium()),
            .titleColor([.normal(Colors.Text.main)])
        ]
    }
}
