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
//  TabBarController.swift

import MacaroonUIKit
import UIKit
import pera_wallet_core

final class TabBarController: TabBarContainer {
    var route: Screen?

    var selectedTab: TabBarItemID? {
        get {
            let item = items[safe: selectedIndex]
            return item.unwrap { TabBarItemID(rawValue: $0.id) }
        }
        set {
            selectedIndex = newValue.unwrap { items.index(of: $0) }
        }
    }

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let analytics: ALGAnalytics
    private let api: ALGAPI

    init(configuration: AppConfiguration) {
        self.analytics = configuration.analytics
        self.api = configuration.api
        super.init()
    }

    override func addTabBar() {
        super.addTabBar()

        tabBar.customizeAppearance(
            [
                .backgroundColor(Colors.Defaults.background)
            ]
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewAppearance([.backgroundColor(Colors.Defaults.background)])
        
        itemDidSelect = { [weak self] index in
            guard let self else { return }
            guard
                selectedIndex == index,
                let nav = selectedScreen as? UINavigationController,
                nav.viewControllers.count > 1 else
            {
                selectedIndex = index
                return
            }
                
            nav.popToRootViewController(animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.appConfiguration?.session.isValid = true
    }

    override func setListeners() {
        super.setListeners()

        self.observeNetworkChanges()
    }
    
    override func selectedIndexDidChange() {
        switch selectedTab {
        case .home:
            analytics.track(.tabBarPressed(type: .tapHome))
        case .discover:
            analytics.track(.tabBarPressed(type: .tapDiscover))
        case .swap:
            analytics.track(.tabBarPressed(type: .tapSwap))
        case .menu:
            analytics.track(.tabBarPressed(type: .tapMenu))
        case .stake:
            analytics.track(.tabBarPressed(type: .tapStake))
        case .collectibles:
            analytics.track(.tabBarPressed(type: .tapNFTs))
        default:
            break
        }
    }
}

extension TabBarController {
    private func observeNetworkChanges() {
        observe(notification: NodeSettingsViewController.didUpdateNetwork) {
            [unowned self] _ in
            setNeedsDiscoverTabBarItemUpdateIfNeeded()
        }
    }

    /// <note>
    /// In staging app, the discover tab is always enabled, but in store app, it is enabled only
    /// on mainnet.
    private var isDiscoverEnabled: Bool {
        return !ALGAppTarget.current.isProduction || !api.isTestNet
    }

    func setNeedsDiscoverTabBarItemUpdateIfNeeded() {
        setTabBarItemEnabled(
            isDiscoverEnabled,
            forItemID: .discover
        )
    }
}
extension Array where Element == TabBarItem {
    func index(
        of itemId: TabBarItemID
    ) -> Int? {
        return firstIndex { $0.id == itemId.rawValue }
    }
}

extension TabBarContainer {
    func setTabBarItemEnabled(
        _ isEnabled: Bool,
        forItemID itemID: TabBarItemID
    ) {
        guard let index = items.index(of: itemID) else {
            return
        }

        let barButton = tabBar.barButtons[index]

        if barButton.isEnabled == isEnabled {
            return
        }

        barButton.isEnabled = isEnabled
    }
}

extension TabBarController {
    func launchDiscover(with destination: DiscoverDestination) {
        selectedTab = .discover

        let container = selectedScreen as? NavigationContainer
        let screen = container?.viewControllers.first as? DiscoverHomeScreen
        screen?.destination = destination
    }
    
    func launchSwap(with draft: SwapAssetFlowDraft? = nil) {
        selectedTab = .swap

        let container = selectedScreen as? NavigationContainer
        guard let screen = container?.viewControllers.first as? SwapViewController, let draft else {
            return
        }
        screen.launchDraft = draft
    }
}

