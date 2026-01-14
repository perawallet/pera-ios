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
        startObservingDeepLinkNotication()
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
    
    private func startObservingDeepLinkNotication() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeepLink(_:)),
            name: .didReceiveDeepLink,
            object: nil
        )
    }
    
    @objc private func handleDeepLink(_ notification: Notification) {
        let path = notification.object as? String
        loadPeraURL(with: path)
    }
}

extension FundInAppBrowserScreen {
    private func generatePeraURL(with path: String?) -> URL? {
        return FundURLGenerator.generateURL(
            theme: traitCollection.userInterfaceStyle,
            session: session,
            path: path
        )
    }

    private func loadPeraURL(with path: String? = nil) {
        let generatedUrl = generatePeraURL(with: path)
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

extension Notification.Name {
    static let didReceiveDeepLink = Notification.Name("didReceiveDeepLink")
}
