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

//   StakingScreen.swift

import Foundation
import WebKit
import MacaroonUtils
import MacaroonUIKit

final class StakingScreen:
    StakingInAppBrowserScreen<StakingScreenScriptMessage>,
    UIScrollViewDelegate {
    
    private lazy var theme = DiscoverHomeScreenTheme()
    private var isViewLayoutLoaded = false

    init(configuration: ViewControllerConfiguration) {
        super.init(
            destination: .list,
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
        webView.scrollView.bounces = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isViewLayoutLoaded {
            return
        }
        isViewLayoutLoaded = true
    }
}

enum StakingScreenScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case none
}
