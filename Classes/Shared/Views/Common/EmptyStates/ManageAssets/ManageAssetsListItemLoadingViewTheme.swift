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

//   ManageAssetsListItemLoadingViewTheme.swift

import Foundation
import MacaroonUIKit

struct ManageAssetsListItemLoadingViewTheme: StyleSheet, LayoutSheet {
    var imageViewCorner: LayoutMetric
    var imageViewSize: LayoutSize

    var textContainerLeadingMargin: LayoutMetric
    
    var titleViewCorner: LayoutMetric
    var titleViewSize: LayoutSize
    
    var subtitleViewCorner: LayoutMetric
    var subtitleViewSize: LayoutSize
    var subtitleTopPadding: LayoutMetric
    
    var actionViewCorner: LayoutMetric
    var actionViewSize: LayoutSize
    
    init(_ family: LayoutFamily) {
        self.imageViewCorner = 20
        self.imageViewSize = (40, 40)
        
        self.textContainerLeadingMargin = 16
        
        self.titleViewCorner = 4
        self.titleViewSize = (114, 20)

        self.subtitleViewCorner = 4
        self.subtitleViewSize = (44, 16)
        self.subtitleTopPadding = 8

        self.actionViewCorner = 8
        self.actionViewSize = (36, 36)
    }
}
