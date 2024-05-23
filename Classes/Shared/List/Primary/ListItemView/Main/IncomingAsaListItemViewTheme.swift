// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsaListItemViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol IncomingAsaListItemViewTheme:
    StyleSheet,
    LayoutSheet {
    var icon: URLImageViewStyleLayoutSheet { get }
    var iconSize: LayoutSize { get }
    var loadingIndicator: ImageStyle { get }
    var loadingIndicatorSize: LayoutSize { get }
    var contentHorizontalPadding: LayoutMetric { get }
    var contentMinWidthRatio: LayoutMetric { get }
    var title: IncominAsaTitleViewTheme { get }
    var primaryValue: TextStyle { get }
    var secondaryValue: TextStyle { get }
    var minSpacingBetweenTitleAndValue: LayoutMetric { get }
}

//struct IncomingAsaListItemViewTheme:
//    StyleSheet,
//    LayoutSheet {
//    
//    var icon: URLImageViewStyleLayoutSheet
//    var iconSize: LayoutSize
//    var loadingIndicator: ImageStyle
//    var loadingIndicatorSize: LayoutSize
//    var contentHorizontalPadding: LayoutMetric
//    var contentMinWidthRatio: LayoutMetric
//    var title: IncominAsaTitleViewTheme
//    var primaryValue: TextStyle
//    var secondaryValue: TextStyle
//    var minSpacingBetweenTitleAndValue: LayoutMetric
//        
//    init(_ family: LayoutFamily) {
//        
//    }
//}
