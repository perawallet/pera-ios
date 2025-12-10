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

//   FundInAppBrowserScreen.swift

import Foundation
import UIKit
import WebKit
import pera_wallet_core

class FundInAppBrowserScreen: InAppBrowserScreen {
    
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }
    
    override var handledMessages: [any InAppBrowserScriptMessage] {
        FundInAppBrowserScriptMessage.allCases
    }

    deinit {
        stopObservingNotifications()
    }

    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)

        startObservingNotifications()
    }
    
    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPeraURL()
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.updateTheme(self.traitCollection.userInterfaceStyle)
        }
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        updateTheme(userInterfaceStyle)
    }

    override func didPullToRefresh() {
        loadPeraURL()
    }
    
    // MARK: - WKScriptMessageHandler
    
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if let inAppMessage = FundInAppBrowserScriptMessage(rawValue: message.name) {
            handleFund(inAppMessage, message)
        }
    }
}

extension FundInAppBrowserScreen {
    private func startObservingNotifications() {
        startObservingAppLifeCycleNotifications()
        startObservingCurrencyChanges()
    }

    private func startObservingAppLifeCycleNotifications() {
        observeWhenApplicationDidBecomeActive {
            [weak self] _ in
            guard let self else { return }
            self.updateTheme(self.traitCollection.userInterfaceStyle)
        }
    }

    private func startObservingCurrencyChanges() {
        observe(notification: CurrencySelectionViewController.didChangePreferredCurrency) {
            [weak self] _ in
            guard let self else { return }
            self.updateCurrency()
        }
    }
}

extension FundInAppBrowserScreen {
    private func generatePeraURL() -> URL? {
        FundURLGenerator.generateURL(
            theme: traitCollection.userInterfaceStyle,
            session: session
        )
    }

    private func loadPeraURL() {
        let generatedUrl = generatePeraURL()
        load(url: generatedUrl)
    }
}

extension FundInAppBrowserScreen {
    private func updateTheme(_ style: UIUserInterfaceStyle) {
        let theme = style.peraRawValue
        let script = "updateTheme('\(theme)')"
        webView.evaluateJavaScript(script)
    }

    private func updateCurrency() {
        guard let newCurrency = session?.preferredCurrencyID.localValue else {
            return
        }
        let script = "updateCurrency('\(newCurrency)')"
        webView.evaluateJavaScript(script)
    }
}

enum FundInAppBrowserScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case handleRequest
}

enum FundInAppBrowserScriptMethod: String {
    case pushWebView
    case openSystemBrowser
    case canOpenURI
    case openNativeURI
    case notifyUser
    case getAddresses
    case getSettings
    case getPublicSettings
    case onBackPressed
    case logAnalyticsEvent
    case closeWebView
}
