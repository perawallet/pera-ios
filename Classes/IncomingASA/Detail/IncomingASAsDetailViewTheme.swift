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
    let contentBackground: Color
    let accountViewTheme: IncomingASADetailAccountViewTheme
    let cellSpacing: LayoutMetric
    let topInset: LayoutMetric
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
    let infoIcon: ImageStyle
    let infoFooterPadding: LayoutMetric
    let infoFooterLeadingInset: LayoutMetric
    let infoFooterTopInset: LayoutMetric
    let infoFooterBottomInset: LayoutMetric
    
    init(_ family: LayoutFamily) {
        self.contentBackground = Colors.Defaults.background
        self.accountViewTheme = IncomingASADetailAccountViewTheme(family)
        self.cellSpacing = 0
        self.topInset = 16
        self.amount = IncomingASARequestHeaderTheme(family)
        self.amountTrailingInset = 20
        self.amountTopInset = 41
        self.copy = IncomingASARequestIdTheme(family)
        self.sendersTitle = [
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular()),
            .textOverflow(SingleLineText())
        ]
        
        self.amountTitle = [
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular()),
            .textOverflow(SingleLineText())
        ]
        self.senders = IncomingASARequesSenderViewTheme(family)
        self.sendersContextPadding = 20
        self.sendersContextTopInset = 16
        self.infoFooter = [
            .textColor(Colors.Text.gray),
            .font(Typography.footnoteRegular()),
            .textOverflow(FittingText())
        ]
        
        self.infoFooterPadding = 20
        self.infoFooterLeadingInset = 8
        self.infoFooterTopInset = 32
        self.infoFooterBottomInset = 120
        self.infoIcon = [
            .image("icon-info-light-gray"),
            .contentMode(.center)
        ]
    }
}

