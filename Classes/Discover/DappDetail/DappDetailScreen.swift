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

//   DappDetailScreen.swift

import Foundation
import WebKit
import MacaroonUtils

final class DappDetailScreen: WebScreen {
    private lazy var navigationTitleView = DappDetailNavigationView()

    private let dappDetail: DiscoverDappDetail

    init(
        dappDetail: DiscoverDappDetail,
        configuration: ViewControllerConfiguration
    ) {
        self.dappDetail = dappDetail
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self

        load(url: URL(string: dappDetail.url))
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = true
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        addNavigationTitle()
    }
}

extension DappDetailScreen {
    private func addNavigationTitle() {
        navigationTitleView.customize(DappDetailNavigationViewTheme())

        navigationItem.titleView = navigationTitleView

        bindNavigationTitle()
    }

    private func bindNavigationTitle() {
        navigationTitleView.bindData(DappDetailNavigationViewModel(dappDetail))
    }
}

extension DappDetailScreen: WKNavigationDelegate {
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
}
