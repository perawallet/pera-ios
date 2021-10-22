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
//   TabBarModalViewTheme.swift

import Foundation
import Macaroon
import UIKit

struct TabBarModalViewTheme: StyleSheet, LayoutSheet {
    let backgroundColor: Color
    let sendButton: ButtonStyle
    let receiveButton: ButtonStyle
    let sendLabel: TextStyle
    let receiveLabel: TextStyle
    let corner: Corner

    let horizontalPadding: LayoutMetric
    let labelTopPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.backgroundColor = AppColors.Shared.System.background
        self.sendButton = [
            .icon("tabbar-icon-send")
        ]
        self.sendLabel = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(15)),
            .textAlignment(.center),
            .content("title-send".localized)
        ]
        self.receiveButton = [
            .icon("tabbar-icon-receive")
        ]
        self.receiveLabel = [
            .textColor(AppColors.Components.Text.main),
            .font(Fonts.DMSans.medium.make(15)),
            .textAlignment(.center),
            .content("title-receive".localized)
        ]
        self.corner = Corner(radius: 16, mask: [.layerMinXMinYCorner, .layerMaxXMinYCorner])

        self.horizontalPadding = 26
        self.labelTopPadding = 12
    }
}
