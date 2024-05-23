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

//   IncomingAsasDetailViewTheme.swift

import Foundation
import MacaroonUIKit

struct IncomingAsasDetailViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let contentBackground: Color
    let dragIndicatorBackground: Color
    let dragIndicatorHeight: LayoutMetric
    let dragIndicatorWidth: LayoutMetric
    let accountAssetsTheme: IncomingASAAccountTheme
    
    let cellSpacing: LayoutMetric
    let topInset: LayoutMetric
    let titleCloseAction: IncomingAsaRequestTitleTheme
    let amount: IncomingAsaRequestHeaderTheme
    let copy: IncomingASARequestIdTheme
    
    let sendersTitle: TextStyle
    let amountTitle: TextStyle
    
    let senders: IncomingAsaSenderViewTheme
    let infoFooter: TextStyle
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.black
        self.contentBackground = Colors.Defaults.background
        self.dragIndicatorBackground = Colors.BottomSheet.line
        self.dragIndicatorHeight = 4
        self.dragIndicatorWidth = 36
        self.accountAssetsTheme = IncomingASAAccountTheme(family)
        self.cellSpacing = 0
        self.topInset = 16
        self.titleCloseAction = IncomingAsaRequestTitleTheme(family)
        self.amount = IncomingAsaRequestHeaderTheme(family)
        self.copy = IncomingASARequestIdTheme(family)
        self.sendersTitle = [
            .textColor(Colors.Text.grayLighter),
            .font(Typography.footnoteRegular()),
            .textOverflow(SingleLineText())
        ]
        
        self.amountTitle = [
            .textColor(Colors.Text.grayLighter),
            .font(Typography.footnoteRegular()),
            .textOverflow(SingleLineText())
        ]
        self.senders = IncomingAsaSenderViewTheme(family)
        self.infoFooter = [
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular()),
            .textOverflow(MultilineText(numberOfLines: 0))
        ]
    }
}

