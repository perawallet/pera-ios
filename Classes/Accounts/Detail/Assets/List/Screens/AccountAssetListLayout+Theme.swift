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
//   AccountAssetListLayout+Theme.swift

import Foundation
import UIKit
import MacaroonUIKit

extension AccountAssetListLayout {
    struct Theme: LayoutSheet, StyleSheet {
        let assetManagementItemSize: LayoutSize
        let searchItemSize: LayoutSize
        let assetLoadingItemSize: LayoutSize
        let chartViewHeight: LayoutMetric

        init(_ family: LayoutFamily) {
            self.assetManagementItemSize = (UIScreen.main.bounds.width - 48, 40)
            self.searchItemSize = (UIScreen.main.bounds.width, 72)
            self.assetLoadingItemSize = (UIScreen.main.bounds.width - 48, 75)
            self.chartViewHeight = 172
        }
    }
}
