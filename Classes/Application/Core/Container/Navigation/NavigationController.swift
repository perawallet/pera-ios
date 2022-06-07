// Copyright 2022 Pera Wallet, LDA

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
//  NavigationController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class NavigationContainer: MacaroonUIKit.NavigationContainer {
    let theme: NavigationContainerTheme

    init(theme: NavigationContainerTheme, rootViewController: UIViewController) {
        self.theme = theme
        super.init(rootViewController: rootViewController)
    }

    /// note: Default theme is WhiteNavigtionContainerTheme
    override init(rootViewController: UIViewController) {
        self.theme = WhiteNavigationContainerTheme()
        super.init(rootViewController: rootViewController)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func customizeNavigationBarAppearance() {
        navigationBar.customizeAppearance(
            theme.navigationStyle
        )
    }
    
    override func customizeViewAppearance() {
        view.customizeAppearance(
            theme.viewStyle
        )
    }
}

protocol NavigationContainerTheme: StyleSheet, LayoutSheet {
    var navigationStyle: NavigationBarStyle { get }
    var viewStyle: ViewStyle { get }
}
