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

//   CarouselBannerItemViewTheme.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct CarouselBannerItemViewTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle
    var contentViewRadius: LayoutMetric
    var contentHorizontalPadding: LayoutMetric
    var text: TextStyle
    var textHeight: LayoutMetric
    var spacingBetweenTextAndIcon: LayoutMetric
    var textHorizontalPadding: LayoutMetric
    var iconViewHeight: LayoutMetric
    var arrowView: ViewStyle
    var arrowViewHeight: LayoutMetric
    var arrow: ImageStyle
    var closeButton: ButtonStyle
    var closeButtonHeight: LayoutMetric
    var closeButtonPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentViewRadius = 16
        self.contentHorizontalPadding = 12
        
        self.text = [
            .textColor(Colors.Text.main),
            .font(Typography.bodyMedium())
        ]
        self.textHeight = 40
        self.spacingBetweenTextAndIcon = 12
        self.textHorizontalPadding = 50
        
        self.iconViewHeight = 48
        
        self.arrowView = [
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.arrowViewHeight = 36
        self.arrow = [
            .image("icon-arrow-24")
        ]
        
        self.closeButton = [
            .backgroundImage([.normal("close-governance-icon")])
        ]
        self.closeButtonHeight = 24
        self.closeButtonPadding  = 8
    }
}
