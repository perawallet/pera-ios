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
    UIScrollViewDelegate {
    var navigationBarScrollView: UIScrollView {
        return webView.scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }
    
    private lazy var theme = DiscoverHomeScreenTheme()

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

        webView.navigationDelegate = self
        webView.scrollView.delegate = self
    }

    /// <mark>
    /// WKScriptMessageHandler
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        let inAppMessage = DiscoverHomeScriptMessage(rawValue: message.name)

        switch inAppMessage {
        case .none:
            super.userContentController(
                userContentController,
                didReceive: message
            )
        case .pushTokenDetailScreen:
            handleTokenDetailAction(message)
        }
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
}

enum DiscoverHomeScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case pushTokenDetailScreen
}
