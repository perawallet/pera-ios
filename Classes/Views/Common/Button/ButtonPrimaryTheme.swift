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
//   ButtonPrimaryTheme.swift

import Macaroon

struct ButtonPrimaryTheme: ButtonTheme {
    var corner: Corner
    let label: TextStyle
    let icon: ImageStyle
    let titleColorSet: ColorSet
    let backgroundColorSet: ColorSet
    let indicator: ImageStyle

    let titleEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.label = [
            .font(Fonts.DMSans.medium.make(15)),
            .textAlignment(.center),
            .textOverflow(.singleLineFitting)
        ]
        self.titleColorSet = ColorSet(
            normal: AppColors.Components.Button.Primary.text,
            disabled: AppColors.Components.Button.Primary.disabledText
        )
        self.backgroundColorSet = ColorSet(
            normal: AppColors.Components.Button.Primary.background,
            disabled: AppColors.Components.Button.Primary.disabledBackground
        )
        self.corner = Corner(radius: 4)
        self.icon = []
        self.indicator = [
            .content(img("button-loading-indicator")),
            .contentMode(.scaleAspectFill)
        ]

        self.titleEdgeInsets = (0, 15, 0, 0)
    }
}
