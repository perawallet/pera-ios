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

//   ManagementItemAccountDetailViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ManagementItemAccountDetailViewTheme:
    StyleSheet,
    LayoutSheet {
    let primaryButton: ButtonStyle
    let secondaryButton: ButtonStyle
    let buttonHeight: LayoutMetric
    let spacing: LayoutMetric
    let cornerRadius: LayoutMetric
    let contentEdgeInsets: UIEdgeInsets
    
    init(_ family: LayoutFamily) {
        self.primaryButton = [
            .titleColor([.normal(Colors.Helpers.positive)]),
            .backgroundColor(Colors.Alert.positive.uiColor.withAlphaComponent(0.12))
        ]
        self.secondaryButton = [
            .titleColor([.normal(Colors.Helpers.positive)]),
            .backgroundColor(Colors.Alert.positive.uiColor.withAlphaComponent(0.12))
        ]
        self.buttonHeight = 40
        self.spacing = 8
        self.cornerRadius = 8
        self.contentEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12)
    }
}
