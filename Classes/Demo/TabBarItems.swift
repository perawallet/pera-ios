// Copyright 2025 Pera Wallet, LDA

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
//  TabBarItems.swift

import Foundation
import MacaroonUIKit
import UIKit

struct HomeTabBarItem: TabBarItem {
    let id: String
    let barButtonItem: MacaroonUIKit.TabBarButtonItem
    let screen: UIViewController?

    init(
        _ screen: UIViewController
    ) {
        self.id = TabBarItemID.home.rawValue
        self.barButtonItem =
            TabBarButtonItem(
                icon: [
                    .normal("tabbar-icon-accounts"),
                    .selected("tabbar-icon-accounts-selected"),
                    .disabled("tabbar-icon-accounts-disabled")
                ],
                title: String(localized: "title-home")
            )
        self.screen = screen
    }
}

struct DiscoverTabBarItem: TabBarItem {
    let id: String
    let barButtonItem: MacaroonUIKit.TabBarButtonItem
    let screen: UIViewController?

    init(
        _ screen: UIViewController
    ) {
        self.id = TabBarItemID.discover.rawValue
        self.barButtonItem =
            TabBarButtonItem(
                icon: [
                    .normal("tabbar-icon-discover"),
                    .selected("tabbar-icon-discover-selected"),
                    .disabled("tabbar-icon-discover-disabled")
                ],
                title: String(localized: "title-discover")
            )
        self.screen = screen
    }
}

struct SwapTabBarItem: TabBarItem {
    let id: String
    let barButtonItem: MacaroonUIKit.TabBarButtonItem
    let screen: UIViewController?

    init(
        _ screen: UIViewController
    ) {
        self.id = TabBarItemID.swap.rawValue
        self.barButtonItem =
            TabBarButtonItem(
                icon: [
                    .normal("tabbar-icon-swap"),
                    .selected("tabbar-icon-swap-selected"),
                    .disabled("tabbar-icon-swap-disabled")
                ],
                title: String(localized: "title-swap")
            )
        self.screen = screen
    }
}

struct StakeTabBarItem: TabBarItem {
    let id: String
    let barButtonItem: MacaroonUIKit.TabBarButtonItem
    let screen: UIViewController?

    init(
        _ screen: UIViewController
    ) {
        self.id = TabBarItemID.stake.rawValue
        self.barButtonItem =
            TabBarButtonItem(
                icon: [
                    .normal("tabbar-icon-stake"),
                    .selected("tabbar-icon-stake-selected"),
                    .disabled("tabbar-icon-stake-disabled")
                ],
                title: String(localized: "title-staking")
            )
        self.screen = screen
    }
}

struct MenuTabBarItem: TabBarItem {
    let id: String
    let barButtonItem: MacaroonUIKit.TabBarButtonItem
    let screen: UIViewController?

    init(
        _ screen: UIViewController
    ) {
        self.id = TabBarItemID.menu.rawValue
        self.barButtonItem =
            TabBarButtonItem(
                icon: [
                    .normal("tabbar-icon-menu"),
                    .selected("tabbar-icon-menu-selected"),
                    .disabled("tabbar-icon-menu-disabled")
                ],
                title: String(localized: "title-menu")
            )
        self.screen = screen
    }
}

enum TabBarItemID: String {
    case home
    case discover
    case swap
    case stake
    case menu
}
