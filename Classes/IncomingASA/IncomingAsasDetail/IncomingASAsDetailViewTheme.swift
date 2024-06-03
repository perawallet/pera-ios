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

struct IncomingASAsDetailViewTheme: LayoutSheet, StyleSheet {
    let backgroundColor: Color
    let contentBackground: Color
    let dragIndicatorBackground: Color
    let dragIndicatorHeight: LayoutMetric
    let dragIndicatorWidth: LayoutMetric
    let accountAssetsTheme: IncomingASADetailHeaderTheme
    let contentTopInset: LayoutMetric
    let contetnCorner: LayoutMetric
    let cellSpacing: LayoutMetric
    let topInset: LayoutMetric
    let titleCloseAction: IncomingASARequestTitleTheme
    let amount: IncomingASARequestHeaderTheme
    let amountTrailingInset: LayoutMetric
    let amountTopInset: LayoutMetric

    let copy: IncomingASARequestIdTheme
    let sendersTitle: TextStyle
    let amountTitle: TextStyle
    
    let senders: IncomingASARequesSenderViewTheme
    let sendersContextPadding: LayoutMetric
    let sendersContextTopInset: LayoutMetric
    let infoFooter: TextStyle
    let infoFooterPadding: LayoutMetric
    let infoFooterTopInset: LayoutMetric
    let infoFooterBottomInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.backgroundColor = Colors.Defaults.black
        self.contentBackground = Colors.Defaults.background
        self.dragIndicatorBackground = Colors.BottomSheet.line
        self.dragIndicatorHeight = 4
        self.dragIndicatorWidth = 36
        self.accountAssetsTheme = IncomingASADetailHeaderTheme(family)
        self.contentTopInset = 200
        self.contetnCorner = 15
        self.cellSpacing = 0
        self.topInset = 16
        self.titleCloseAction = IncomingASARequestTitleTheme(family)
        self.amount = IncomingASARequestHeaderTheme(family)
        self.amountTrailingInset = 20
        self.amountTopInset = 41
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
        self.senders = IncomingASARequesSenderViewTheme(family)
        self.sendersContextPadding = 20
        self.sendersContextTopInset = 16
        self.infoFooter = [
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular()),
            .textOverflow(MultilineText(numberOfLines: 0))
        ]
        
        self.infoFooterPadding = 20
        self.infoFooterTopInset = 32
        self.infoFooterBottomInset = 120
    }
}

