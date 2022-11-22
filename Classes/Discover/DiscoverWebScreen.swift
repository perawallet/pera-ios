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

//   DiscoverWebScreen.swift

import Foundation
import WebKit
import MacaroonUtils
import MacaroonUIKit

final class DiscoverWebScreen:
    WebScreen,
    NavigationBarLargeTitleConfigurable,
    UIScrollViewDelegate {
    var navigationBarScrollView: UIScrollView {
        return webView.scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private lazy var theme = DiscoverWebScreenTheme()

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = DiscoverNavigationBarView()

    private lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)

    private var isNavigationTitleHidden = true
    private var isLayoutFinalized = false

    private var events: [Event] = [.tokenDetail, .dAppViewer]

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        navigationBarLargeTitleController.title = "title-discover".localized
        navigationBarLargeTitleController.additionalScrollEdgeOffset = theme.webContentTopInset

        navigationBarLargeTitleView.searchAction = {
            [unowned self] in
            self.navigateToSearch()
        }

        updateRightBarButtonsWhenNavigationTitleBecomeHidden(true)
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addNavigationBarLargeTitle()

        navigationBarLargeTitleController.activate()

        webView.navigationDelegate = self
        webView.scrollView.delegate = self

        events.forEach { event in
            contentController.add(self, name: event.rawValue)
        }

        let generatedUrl = DiscoverURLGenerator.generateUrl(
            from: .home,
            on: interfaceTheme,
            with: session
        )
        load(url: generatedUrl)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isLayoutFinalized {
            return
        }

        updateUIWhenViewDidLayout()

        isLayoutFinalized = true
    }
}

/// <mark>
/// UIScrollViewDelegate
extension DiscoverWebScreen {
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

extension DiscoverWebScreen {
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

extension DiscoverWebScreen {
    private func updateUIWhenViewDidLayout() {
        updateAdditionalSafeAreaInetsWhenViewDidLayout()
    }

    private func updateAdditionalSafeAreaInetsWhenViewDidLayout() {
        webView.scrollView.contentInset.top = navigationBarLargeTitleView.bounds.height + theme.webContentTopInset
    }
}

extension DiscoverWebScreen: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let jsonString = message.body as? String,
              let jsonData = jsonString.data(using: .utf8) else {
            return
        }

        let jsonDecoder = JSONDecoder()

        if let tokenDetail = try? jsonDecoder.decode(DiscoverTokenDetail.self, from: jsonData) {
            openTokenDetail(tokenDetail)
            return
        }

        if let dappDetail = try? jsonDecoder.decode(DiscoverDappDetail.self, from: jsonData) {
            openDappDetail(dappDetail)
            return
        }
    }

    private func openDappDetail(_ dappDetail: DiscoverDappDetail) {
        open(
            .discoverDappDetail(dappDetail),
            by: .push
        )
    }

    private func openTokenDetail(_ tokenDetail: DiscoverTokenDetail) {
        open(
            .discoverAssetDetail(tokenDetail),
            by: .push
        )
    }
}

extension DiscoverWebScreen {
    private func navigateToSearch() {
        let screen = Screen.discoverSearch { [weak self] event, screen in
            guard let self else {
                return
            }

            switch event {
            case .selectAsset(let tokenDetail):
                screen.dismissScreen(animated: true) {
                    self.openTokenDetail(tokenDetail)
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

extension DiscoverWebScreen {
    enum Event: String {
        case tokenDetail = "pushTokenDetailScreen"
        case dAppViewer = "pushDappViewerScreen"
    }
}
