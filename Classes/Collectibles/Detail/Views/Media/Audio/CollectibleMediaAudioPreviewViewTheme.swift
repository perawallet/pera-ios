// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleMediaAudioPreviewViewTheme.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

struct CollectibleMediaAudioPreviewViewTheme:
    StyleSheet,
    LayoutSheet {
    let placeholder: URLImagePlaceholderViewLayoutSheet & URLImagePlaceholderViewStyleSheet
    
    let threeDAction: ButtonStyle
    let threeDActionContentEdgeInsets: LayoutPaddings
    let threeDActionPaddings: LayoutPaddings
    
    let fullScreenAction: ButtonStyle
    let fullScreenBadgePaddings: LayoutPaddings
    
    let corner: Corner
    
    init(_ family: LayoutFamily) {
        self.placeholder = PlaceholerViewTheme()
        
        self.threeDAction = [
            .icon([
                .normal("icon-3d"),
                .highlighted("icon-3d")
            ]),
            .backgroundImage([
                .normal("icon-3d-bg"),
                .highlighted("icon-3d-bg")
            ]),
            .titleColor([
                .normal(Colors.Text.white)
            ]),
            .title("collectible-detail-tap-3D".localized.footnoteMedium()),
        ]
        self.threeDActionContentEdgeInsets = (4, 8, 4, 8)
        self.threeDActionPaddings = (.noMetric, 16, 16, .noMetric)

        
        self.fullScreenAction = [
            .icon([
                .normal("icon-full-screen"),
                .highlighted("icon-full-screen")
            ])
        ]
        self.fullScreenBadgePaddings = (.noMetric, .noMetric, 16, 16)
        
        self.corner = Corner(radius: 12)
    }
}

extension CollectibleMediaAudioPreviewViewTheme {
    struct PlaceholerViewTheme:
        URLImagePlaceholderViewLayoutSheet,
        URLImagePlaceholderViewStyleSheet {

        var textPaddings: LayoutPaddings
        var background: ViewStyle
        var image: ImageStyle
        var text: TextStyle

        init(
            _ family: LayoutFamily
        ) {
            textPaddings = (8, 8, 8, 8)
            background = [
                .backgroundColor(Colors.Layer.grayLighter)
            ]
            image = []
            text = [
                .textColor(Colors.Text.gray),
                .textOverflow(FittingText())
            ]
        }
    }
}
