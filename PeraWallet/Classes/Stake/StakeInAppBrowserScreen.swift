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

//   StakingInAppBrowserScreen.swift

import UIKit
import WebKit
import pera_wallet_core

class StakingInAppBrowserScreen: InAppBrowserScreen {
    
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }
    
    override var extraUserScripts: [InAppBrowserScript] { [.navigation, .peraConnect] }
    
    override var handledMessages: [any InAppBrowserScriptMessage] {
        StakingInAppBrowserScreenMessage.allCases
    }

    var destination: StakingDestination {
        didSet { loadStakingURL() }
    }
    
    var hideBackButtonInWebView: Bool = true
    
    init(
        destination: StakingDestination,
        configuration: ViewControllerConfiguration
    ) {
        self.destination = destination
        super.init(configuration: configuration)
        
        if configuration.featureFlagService.isEnabled(.xoSwapEnabled) {
            hideBackButtonInWebView = false
        }

        startObservingNotifications()
        allowsPullToRefresh = false
    }

    deinit {
        stopObservingNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStakingURL()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.updateTheme(self.traitCollection.userInterfaceStyle)
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        updateTheme(userInterfaceStyle)
    }

    override func didPullToRefresh() {
        loadStakingURL()
    }
    
    // MARK: - WKScriptMessageHandler
    
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if let inAppMessage = StakingInAppBrowserScreenMessage(rawValue: message.name) {
            handleStaking(inAppMessage, message)
        }
    }
}

extension StakingInAppBrowserScreen {
    private func startObservingNotifications() {
        startObservingAppLifeCycleNotifications()
    }

    private func startObservingAppLifeCycleNotifications() {
        observeWhenApplicationDidBecomeActive {
            [weak self] _ in
            guard let self else { return }
            self.updateTheme(self.traitCollection.userInterfaceStyle)
        }
    }
}

extension StakingInAppBrowserScreen {
    private func generatePeraURL() -> URL? {
        StakingURLGenerator.generateURL(
            destination: destination,
            theme: traitCollection.userInterfaceStyle,
            session: session
        )
    }

    private func loadStakingURL() {
        let generatedUrl = generatePeraURL()
        load(url: generatedUrl)
    }
}

extension StakingInAppBrowserScreen {
    private func updateTheme(_ style: UIUserInterfaceStyle) {
        let theme = style.peraRawValue
        let script = "updateTheme('\(theme)')"
        webView.evaluateJavaScript(script)
    }
}

enum StakingInAppBrowserScreenMessage:
    String,
    InAppBrowserScriptMessage {
    case openSystemBrowser
    case closeWebView
    case peraconnect
    case requestDeviceID = "getDeviceId"
    case openDappWebview
}
