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

//   ASADetailViewControllerTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ASADetailViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    var navigationTitle: AccountNameTitleViewTheme
    var loading: ASADetailViewControllerLoadingViewTheme
    var error: NoContentWithActionViewCommonTheme
    var errorBackground: ViewStyle
    var profile: ASAProfileViewTheme
    var quickActions: ASADetailQuickActionsViewTheme
    var horizontalPadding: LayoutMetric
    var quickActionsTopPadding: LayoutMetric
    var quickActionsBottomPadding: LayoutMetric

    init(_ family: LayoutFamily) {
        self.navigationTitle = AccountNameTitleViewTheme(family)
        self.loading = ASADetailViewControllerLoadingViewTheme()
        self.error = NoContentWithActionViewCommonTheme()
        self.errorBackground = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.profile = ASAProfileViewTheme(family)
        self.quickActions = ASADetailQuickActionsViewTheme(family)
        
        self.horizontalPadding = 25
        self.quickActionsTopPadding = 30
        self.quickActionsBottomPadding = 40
    }
}
