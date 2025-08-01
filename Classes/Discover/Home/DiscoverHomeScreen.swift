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

//   DiscoverHomeScreen.swift

import Foundation
import WebKit
import MacaroonUtils
import MacaroonUIKit

final class DiscoverHomeScreen:
    DiscoverInAppBrowserScreen<DiscoverHomeScriptMessage>,
    NavigationBarLargeTitleConfigurable,
    UIScrollViewDelegate {
    var navigationBarScrollView: UIScrollView {
        return webView.scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }
    
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: SwapDataLocalStore(),
        analytics: analytics,
        api: api!,
        sharedDataController: sharedDataController,
        loadingController: loadingController!,
        bannerController: bannerController!,
        hdWalletStorage: hdWalletStorage,
        presentingScreen: self
    )
    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )
    
    private lazy var theme = DiscoverHomeScreenTheme()

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = DiscoverNavigationBarView()

    private lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)

    private var isNavigationTitleHidden = true
    private var isViewLayoutLoaded = false

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    init(configuration: ViewControllerConfiguration) {
        super.init(
            destination: .home,
            configuration: configuration
        )
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarLargeTitleController.deactivate()

        webView.navigationDelegate = self
        webView.scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    /// <mark>
    /// WKScriptMessageHandler
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let inAppMessage = DiscoverHomeScriptMessage(rawValue: message.name) else {
            super.userContentController(userContentController, didReceive: message)
            return
        }

        switch inAppMessage {
        case .pushTokenDetailScreen:
            handleTokenDetailAction(message)
        case .swap, .handleTokenDetailActionButtonClick:
            handleTokenAction(message)
        }
    }
}

/// <mark>
/// UIScrollViewDelegate
extension DiscoverHomeScreen {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUIWhenWebContentDidScroll()
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        navigationBarLargeTitleController.scrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset,
            contentOffsetDeltaYBelowLargeTitle: 0
        )
    }
}

extension DiscoverHomeScreen {
    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(
                theme.navigationBarEdgeInset
            )
        }
    }

    private func updateUIWhenWebContentDidScroll() {
        updateNavigationRightBarButtonsWhenWebContentDidScroll()
    }

    private func updateNavigationRightBarButtonsWhenWebContentDidScroll() {
        let isHidden = navigationBarLargeTitleView.frame.maxY >= 0
        updateRightBarButtonsWhenNavigationTitleBecomeHidden(isHidden)
    }

    private func updateRightBarButtonsWhenNavigationTitleBecomeHidden(_ hidden: Bool) {
        if isNavigationTitleHidden == hidden { return }

        if hidden {
            rightBarButtonItems = []
        } else {
            rightBarButtonItems = [ makeSearchBarButtonItem() ]
        }

        setNeedsRightBarButtonItemsUpdate()

        isNavigationTitleHidden = hidden
    }

    private func makeSearchBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .search) {
            [unowned self] in
            self.navigateToSearch()
        }
    }
}

extension DiscoverHomeScreen {
    private func updateUIWhenViewDidLayout() {
        updateAdditionalSafeAreaInetsWhenViewDidLayout()
    }

    private func updateAdditionalSafeAreaInetsWhenViewDidLayout() {
        webView.scrollView.contentInset.top = navigationBarLargeTitleView.bounds.height + theme.webContentTopInset
    }
}

extension DiscoverHomeScreen {
    private func handleTokenDetailAction(_ message: WKScriptMessage) {
        guard let jsonString = message.body as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let params = try? DiscoverAssetParameters.decoded(jsonData) else { return }
        navigateToAssetDetail(params)
    }

    private func navigateToAssetDetail(_ params: DiscoverAssetParameters) {
        open(
            .discoverAssetDetail(params),
            by: .push
        )
    }
    
    private func handleTokenAction(_ message: WKScriptMessage) {
        guard let jsonString = message.body as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let params = try? DiscoverSwapParameters.decoded(jsonData) else { return }
        
        switch params.action {
        case .buyAlgo:
            navigateToBuyAlgo()
        default:
            navigateToSwap(with: params)
        }
        
        sendAnalyticsEvent(with: params)
    }
    
    private func navigateToBuyAlgo() {
        meldFlowCoordinator.launch()
    }

    private func navigateToSwap(with parameters: DiscoverSwapParameters) {
        let draft = SwapAssetFlowDraft()
        if let assetInID = parameters.assetIn {
            draft.assetInID = assetInID
        }
        if let assetOutID = parameters.assetOut {
            draft.assetOutID = assetOutID
        }

        swapAssetFlowCoordinator.updateDraft(draft)
        swapAssetFlowCoordinator.launch()
    }
    
    private func sendAnalyticsEvent(with parameters: DiscoverSwapParameters) {
        let assetInID = parameters.assetIn
        let assetOutID = parameters.assetOut

        switch parameters.action {
        case .buyAlgo:
            self.analytics.track(.buyAssetFromDiscover(assetOutID: 0, assetInID: nil))
        case .swapFromAlgo:
            self.analytics.track(.sellAssetFromDiscover(assetOutID: assetOutID, assetInID: 0))
        case .swapToAsset:
            guard let assetOutID else { return }
            self.analytics.track(.buyAssetFromDiscover(assetOutID: assetOutID, assetInID: assetInID))
        case .swapFromAsset:
            self.analytics.track(.sellAssetFromDiscover(assetOutID: assetOutID, assetInID: assetInID))
        }
    }
}

extension DiscoverHomeScreen {
    private func navigateToSearch() {
        let screen = Screen.discoverSearch {
            [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .selectAsset(let assetDetail):
                screen.dismissScreen(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.navigateToAssetDetail(assetDetail)
                }
            }
        }

        open(
            screen,
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        )
    }
}

enum DiscoverHomeScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case pushTokenDetailScreen
    case swap
    case handleTokenDetailActionButtonClick
}
