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

//   CardsInAppBrowserScreen.swift

import Foundation
import UIKit
import WebKit
import pera_wallet_core

class CardsInAppBrowserScreen: InAppBrowserScreen {
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }
    
    override var extraUserScripts: [InAppBrowserScript] { [.navigation, .peraConnect] }
    
    override var handledMessages: [any InAppBrowserScriptMessage] {
        CardsInAppBrowserScriptMessage.allCases
    }

    var destination: CardsDestination {
        didSet { loadCardsURL() }
    }
    
    init(
        destination: CardsDestination,
        configuration: ViewControllerConfiguration
    ) {
        self.destination = destination
        super.init(configuration: configuration)
        
        startObservingNotifications()
        allowsPullToRefresh = false
    }

    deinit {
        stopObservingNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCardsURL()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        loadCardsURL()
    }
}

private extension CardsInAppBrowserScreen {
    func startObservingNotifications() {
        startObservingAppLifeCycleNotifications()
    }

    func startObservingAppLifeCycleNotifications() {
        observeWhenApplicationDidBecomeActive {
            [weak self] _ in
            guard let self else { return }
            self.updateTheme(self.traitCollection.userInterfaceStyle)
        }
    }
}

private extension CardsInAppBrowserScreen {
    func generatePeraURL() -> URL? {
        CardsURLGenerator.generateURL(
            destination: destination,
            theme: traitCollection.userInterfaceStyle,
            session: session,
            network: api?.network ?? .mainnet
        )
    }

    func loadCardsURL() {
        let generatedUrl = generatePeraURL()
        load(url: generatedUrl)
    }
}

private extension CardsInAppBrowserScreen {
    func updateTheme(_ style: UIUserInterfaceStyle) {
        let theme = style.peraRawValue
        let script = "updateTheme('\(theme)')"
        webView.evaluateJavaScript(script)
    }
}

enum CardsInAppBrowserScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case requestAuthorizedAddresses = "getAuthorizedAddresses"
    case openSystemBrowser
    case closePeraCards
    case peraconnect
    case requestDeviceID = "getDeviceId"
}
