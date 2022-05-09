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

//   CollectibleMediaImagePreviewViewTheme.swift

import MacaroonUIKit
import MacaroonURLImage

struct CollectibleMediaImagePreviewViewTheme:
    StyleSheet,
    LayoutSheet {
    let image: URLImageViewStyleLayoutSheet
    let overlay: ViewStyle
    let corner: Corner

    init(
        _ family: LayoutFamily
    ) {
        self.image = URLImageViewCollectibleMediaTheme()
        self.overlay = [
            .backgroundColor(AppColors.Shared.System.background)
        ]
        
        self.corner = Corner(radius: 4)
    }
}

struct URLImageViewCollectibleMediaTheme:
    URLImageViewStyleSheet,
    URLImageViewLayoutSheet {
    struct PlaceholderLayoutSheet: URLImagePlaceholderViewLayoutSheet {
        let textPaddings: LayoutPaddings

        init(
            _ family: LayoutFamily
        ) {
            textPaddings = (8, 8, 8, 8)
        }
    }

    struct PlaceholderStyleSheet: URLImagePlaceholderViewStyleSheet {
        let background: ViewStyle
        let image: ImageStyle
        let text: TextStyle

        init() {
            background = [
                .backgroundColor(AppColors.Shared.Layer.grayLighter)
            ]
            image = []
            text = [
                .textColor(AppColors.Components.Text.gray),
                .textOverflow(FittingText())
            ]
        }
    }

    let background: ViewStyle
    let content: ImageStyle
    let placeholderStyleSheet: URLImagePlaceholderViewStyleSheet?
    let placeholderLayoutSheet: URLImagePlaceholderViewLayoutSheet?

    init(
        _ family: LayoutFamily
    ) {
        background = []
        content = .aspectFit()
        placeholderStyleSheet = PlaceholderStyleSheet()
        placeholderLayoutSheet = PlaceholderLayoutSheet()
    }
}
