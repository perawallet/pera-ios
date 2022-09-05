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
//   WCSessionItemViewTheme.swift

import MacaroonUIKit
import UIKit

struct WCSessionItemViewTheme: LayoutSheet, StyleSheet {
    let horizontalPadding: LayoutMetric
    let image: URLImageViewStyleLayoutSheet
    let imageSize: LayoutSize
    let imageBorder: Border
    let imageCorner: Corner
    let name: TextStyle
    let nameHorizontalPadding: LayoutMetric
    let optionsAction: ButtonStyle
    let descriptionTopPadding: LayoutMetric
    let description: TextStyle
    let dateTopPadding: LayoutMetric
    let date: TextStyle
    let statusTopPadding: LayoutMetric
    let status: TextStyle
    let statusContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        horizontalPadding = 24
        image = URLImageViewNoStyleLayoutSheet()
        imageSize = (40, 40)
        imageBorder = Border(
            color: Colors.Layer.grayLighter.uiColor,
            width: 1
        )
        imageCorner = Corner(radius: imageSize.h / 2)
        name = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        nameHorizontalPadding = 16
        description = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.gray),
        ]
        descriptionTopPadding = 8
        optionsAction = [
            .icon([ .normal("icon-options") ])
        ]
        date = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.grayLighter)
        ]
        dateTopPadding = 12
        status = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Helpers.positive),
            .backgroundColor(Colors.Helpers.positive.uiColor.withAlphaComponent(0.1))
        ]
        statusTopPadding = 10
        statusContentEdgeInsets = (2, 8, 2, 8)
    }
}
