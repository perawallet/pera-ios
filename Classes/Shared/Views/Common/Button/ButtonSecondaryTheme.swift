// Copyright 2022-2025 Pera Wallet, LDA

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
//   ButtonSecondaryTheme.swift

import MacaroonUIKit

struct ButtonSecondaryTheme: ButtonTheme {
    var corner: Corner
    let label: TextStyle
    let icon: ImageStyle
    let titleColorSet: StateColorGroup
    let backgroundColorSet: StateColorGroup
    let indicator: ImageStyle

    let contentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.label = [
            .isInteractable(false),
            .font(Fonts.DMSans.medium.make(15)),
            .textAlignment(.center),
            .textOverflow(SingleLineFittingText())
        ]
        self.titleColorSet = [
            .normal(Colors.Button.Secondary.text),
            .disabled(Colors.Button.Secondary.disabledText)
        ]
        self.backgroundColorSet = [
            .normal(Colors.Button.Secondary.background),
            .disabled(Colors.Button.Secondary.disabledBackground)
        ]
        self.corner = Corner(radius: 4)
        self.icon = [
            .isInteractable(false)
        ]
        self.indicator = [
            .isInteractable(false),
            .image("button-loading-indicator"),
            .contentMode(.scaleAspectFill)
        ]
        
        self.contentEdgeInsets = (14, 0, 14, 0)
    }
}
