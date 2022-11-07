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

final class DiscoverWebScreen: WebScreen, NavigationBarLargeTitleConfigurable {
    private lazy var theme = DiscoverWebScreenTheme()
    private var events: [Event] = [.tokenDetail, .dAppViewer]

    var navigationBarScrollView: UIScrollView {
        webView.scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = DiscoverNavigationBarView()

    private lazy var navigationBarLargeTitleController =
    NavigationBarLargeTitleController(screen: self)

    private var isLayoutFinalized = false
    private lazy var interfaceTheme: Theme = isDarkMode ? .dark : .light {
        didSet {
            // send js event to adopt theme change
        }
    }

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarLargeTitleController.activate()
        webView.navigationDelegate = self

        events.forEach { event in
            contentController.add(self, name: event.rawValue)
        }

        load(url: URL(string: "https://discover-mobile-staging.perawallet.app/?theme=\(interfaceTheme.rawValue)"))
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection != previousTraitCollection else {
            return
        }

        if traitCollection.userInterfaceStyle == .dark {
            self.interfaceTheme = .dark
        } else {
            self.interfaceTheme = .light
        }
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        navigationBarLargeTitleController.title = "title-discover".localized

        navigationBarLargeTitleView.searchAction = { [weak self] in
            guard let self else {
                return
            }

            print("search")
        }
    }

    override func prepareLayout() {
        super.prepareLayout()

        addNavigationBarLargeTitle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isLayoutFinalized {
            return
        }

        updateUIWhenViewDidLayout()

        isLayoutFinalized = true
    }

    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(
                theme.navigationBarEdgeInset
            )
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
extension DiscoverWebScreen: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {
        if let requestUrl = navigationAction.request.url {
            let deeplinkQR = DeeplinkQR(url: requestUrl)

            if let walletConnectURL = deeplinkQR.walletConnectUrl() {
                AppDelegate.shared!.receive(deeplinkWithSource: .walletConnectSessionRequest(walletConnectURL))
                decisionHandler(.cancel, preferences)
                return
            }

            decisionHandler(.allow, preferences)

            return
        }

        decisionHandler(.allow, preferences)
    }

    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard (webView.url?.host) != nil else {
            return
        }

        let authenticationMethod = challenge.protectionSpace.authenticationMethod

        if authenticationMethod == NSURLAuthenticationMethodDefault || authenticationMethod == NSURLAuthenticationMethodHTTPBasic || authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
            let credential = URLCredential(user: "pera-discover-web", password: "AJWYX*Z9$mK49Td9", persistence: .forSession)
            completionHandler(.useCredential, credential)
        } else if authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.performDefaultHandling, nil)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension DiscoverWebScreen: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let jsonString = message.body as? String, let jsonData = jsonString.data(using: .utf8) else {
            return
        }

        let jsonDecoder = JSONDecoder()

        if let tokenDetail = try? jsonDecoder.decode(DiscoverTokenDetail.self, from: jsonData) {
            print(tokenDetail.tokenId)
        } else if let dappDetail = try? jsonDecoder.decode(DiscoverDappDetail.self, from: jsonData) {
            routeDappDetail(dappDetail)
        }
    }

    private func routeDappDetail(_ dappDetail: DiscoverDappDetail) {
        self.navigationController?.pushViewController(DappDetailScreen(configuration: configuration, dappModel: dappDetail), animated: true)
    }
}

extension DiscoverWebScreen {
    enum Event: String {
        case tokenDetail = "pushTokenDetailScreen"
        case dAppViewer = "pushDappViewerScreen"
    }

    enum Theme: String {
        case dark = "dark-theme"
        case light = "light-theme"
    }
}
