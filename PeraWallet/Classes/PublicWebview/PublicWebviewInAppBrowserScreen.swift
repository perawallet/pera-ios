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

//   PublicWebviewInAppBrowserScreen.swift

import UIKit
import WebKit
import pera_wallet_core

class PublicWebviewInAppBrowserScreen: InAppBrowserScreen {
    
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }
    
    override var handledMessages: [any InAppBrowserScriptMessage] {
        PublicWebviewInAppBrowserScreenMessage.allCases
    }
    
    private let url: URL?
    
    var hideBackButtonInWebView: Bool = false
    
    init(
        url: URL?,
        configuration: ViewControllerConfiguration
    ) {
        self.url = url
        super.init(configuration: configuration)

        startObservingNotifications()
        allowsPullToRefresh = false
    }

    deinit {
        stopObservingNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadURL()
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
        loadURL()
    }
    
    private func loadURL() {
        load(url: url)
    }
    
    // MARK: - WKScriptMessageHandler
    
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if let inAppMessage = PublicWebviewInAppBrowserScreenMessage(rawValue: message.name) {
            handlePublicWebview(inAppMessage, message)
        }
    }
}

extension PublicWebviewInAppBrowserScreen {
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

extension PublicWebviewInAppBrowserScreen {
    private func updateTheme(_ style: UIUserInterfaceStyle) {
        let theme = style.peraRawValue
        let script = "updateTheme('\(theme)')"
        webView.evaluateJavaScript(script)
    }
}

enum PublicWebviewInAppBrowserScreenMessage:
    String,
    InAppBrowserScriptMessage {
    case openSystemBrowser
    case closeWebView
    case pushWebView
    case getPublicSettings
    case onBackPressed
    case logAnalyticsEvent
}
