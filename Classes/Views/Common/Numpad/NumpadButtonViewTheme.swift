// Copyright 2019 Algorand, Inc.

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
//   NumpadButtonViewTheme.swift

import Foundation
import Macaroon
import UIKit

struct NumpadButtonViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let deleteImage: ImageStyle
    let button: ButtonStyle
    let buttonBackgroundHighlightedImage: ImageStyle

    let stackViewSpacing: LayoutMetric
    let stackViewHeight: LayoutMetric

    let size = CGSize(width: 72.0 * verticalScale, height: 72.0 * verticalScale)

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.deleteImage = [
            .content(img("icon-delete-number"))
        ]

        self.button = [
            .font(Fonts.DMMono.regular.make(24).font),
            .titleColor(AppColors.Components.Button.Ghost.text.color)
        ]
        self.buttonBackgroundHighlightedImage = [
            .content(img("bg-passcode-number-selected"))
        ]

        self.stackViewSpacing = 24 * verticalScale
        self.stackViewHeight = 72 * verticalScale
    }
}
