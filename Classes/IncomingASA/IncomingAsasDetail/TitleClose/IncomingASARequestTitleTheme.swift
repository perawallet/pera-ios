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

//   IncomingAsaRequestTitleTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct IncomingASARequestTitleTheme:
    LayoutSheet,
    StyleSheet {
    
    let backgroundColor: Color
    let container: ViewStyle
    let action: ButtonStyle
    let closeActionViewPaddings: LayoutPaddings
    let titleViewHorizontalPaddings: LayoutHorizontalPaddings
    let title: TextStyle
    
    init(_ family: LayoutFamily) {
        
        self.backgroundColor = Colors.Defaults.black

        self.container = [
            .backgroundColor(Colors.Defaults.background),
        ]
        
        let closeActionIcon = "icon-close"
            .uiImage
            .withRenderingMode(.alwaysTemplate)
        self.action = [
            .icon([
                .normal(closeActionIcon)
            ]),
            .tintColor(Colors.Text.main)
        ]
        
        closeActionViewPaddings = (30, 20, .noMetric, .noMetric)
        titleViewHorizontalPaddings = (8, 24)

        self.title = [
            .textColor(Colors.Text.main),
            .textOverflow(SingleLineText())
        ]
    }
}
