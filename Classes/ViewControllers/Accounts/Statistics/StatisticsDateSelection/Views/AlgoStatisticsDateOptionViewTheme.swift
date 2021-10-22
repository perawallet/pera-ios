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
//   AlgoStatisticsDateOptionViewTheme.swift

import Macaroon

struct AlgoStatisticsDateOptionViewTheme: LayoutSheet, StyleSheet {
    let title: TextStyle
    let selectedImage: ImageStyle
    let selectedImageSize: LayoutSize

    let horizontalPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.title = [
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Components.Text.main)
        ]
        self.selectedImage = [
            .content("icon-circle-check")
        ]

        self.selectedImageSize = (40, 40)
        self.horizontalPadding = 24
    }
}
