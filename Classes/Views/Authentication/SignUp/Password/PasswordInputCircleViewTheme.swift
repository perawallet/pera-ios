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
//   PasswordInputCircleViewTheme.swift

import Foundation
import Macaroon
import UIKit

struct PasswordInputCircleViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let imageSet: ImageSet
    let negativeTintColor: Color
    let contentMode: UIView.ContentMode

    let size: LayoutSize
    let corner: Corner

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        let filledButtonImage: UIImage = img("black-button-filled")
        self.imageSet = ImageSet(
            img("gray-button-border"),
            highlighted: filledButtonImage,
            selected: filledButtonImage,
            disabled: filledButtonImage
        )
        self.negativeTintColor = AppColors.Shared.Helpers.negative
        self.contentMode = .center

        self.size = (20, 20)
        self.corner = Corner(radius: 10)
    }
}
