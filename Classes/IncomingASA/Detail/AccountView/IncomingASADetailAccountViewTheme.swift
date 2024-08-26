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

//   IncomingASADetailAccountViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct IncomingASADetailAccountViewTheme: StyleSheet, LayoutSheet {
    let dividerLine: ViewStyle
    let dividerLineMinWidth: LayoutMetric
    let dividerLineHeight: LayoutMetric
    let idSeperatorPadding: LayoutMetric
    let idSeperatorTopInset: LayoutMetric
    let backgroundColor: Color
    let icon: ImageStyle
    let iconSize: LayoutSize
    let horizontalPadding: LayoutMetric
    let contentMinWidthRatio: LayoutMetric
    let title: TextStyle
    let accountNameTitle: TextStyle
    var height: CGFloat
    
    init(_ family: LayoutFamily) {
        self.dividerLine = [ .backgroundColor(Colors.Layer.grayLighter) ]
        self.dividerLineMinWidth = 40
        self.dividerLineHeight = 1
        self.backgroundColor = Colors.Defaults.background
        self.icon = [
            .contentMode(.scaleAspectFit)
        ]
        self.iconSize = (24, 24)
        self.horizontalPadding = 20
        self.contentMinWidthRatio = 0.25
        self.title = [
            .textColor(Colors.Text.gray),
            .font(Typography.bodyRegular()),
            .textOverflow(SingleLineText())
        ]
        self.accountNameTitle = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyRegular())
        ]
        self.height = 45
        self.idSeperatorPadding = 20
        self.idSeperatorTopInset = 16
    }
}
