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

class CardsInAppBrowserScreen<ScriptMessage>: InAppBrowserScreen<ScriptMessage>
where ScriptMessage: InAppBrowserScriptMessage {
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }
    
    override var extraUserScripts: [InAppBrowserScript] { [.navigation, .peraConnect] }

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

    override func createUserContentController() -> InAppBrowserUserContentController {
        let controller = super.createUserContentController()
        CardsInAppBrowserScriptMessage.allCases.forEach {
            controller.add(
                secureScriptMessageHandler: self,
                forMessage: $0
            )
        }
        return controller
    }

    /// <mark>
    /// WKScriptMessageHandler
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        let inAppMessage = CardsInAppBrowserScriptMessage(rawValue: message.name)
        switch inAppMessage {
        case .none:
            super.userContentController(
                userContentController,
                didReceive: message
            )
        case .requestAuthorizedAddresses:
            let handler = BrowserAuthorizedAddressEventHandler(sharedDataController: sharedDataController)
            handler.returnAuthorizedAccounts(message, in: webView, isAuthorizedAccountsOnly: true)
        case .openSystemBrowser:
            handleOpenSystemBrowser(message)
        case .closePeraCards:
            dismissScreen()
        case .peraconnect:
            handlePeraConnectAction(message)
        case .requestDeviceID:
            handleDeviceIDRequest(message)
        }
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

private extension CardsInAppBrowserScreen {
    func handleOpenSystemBrowser(_ message: WKScriptMessage) {
        if !message.isAcceptable { return }
      
        guard let jsonString = message.body as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let params = try? DiscoverGenericParameters.decoded(jsonData) else { return }

        openInBrowser(params.url)
    }
}

private extension CardsInAppBrowserScreen {
    func handlePeraConnectAction(_ message: WKScriptMessage) {
        guard let jsonString = message.body as? String else { return }
        guard let url = URL(string: jsonString) else { return }
        guard let walletConnectURL = DeeplinkQR(url: url).walletConnectUrl() else { return }

        let src: DeeplinkSource = .walletConnectSessionRequestForDiscover(walletConnectURL)
        launchController.receive(deeplinkWithSource: src)
    }
}

private extension CardsInAppBrowserScreen {
    func handleDeviceIDRequest(_ message: WKScriptMessage) {
        if !message.isAcceptable { return }
        guard let deviceIDDetails = makeDeviceIDDetails() else { return }

        let scriptString = "var message = '" + deviceIDDetails + "'; handleMessage(message);"
        self.webView.evaluateJavaScript(scriptString)
    }

    func makeDeviceIDDetails() -> String? {
        guard let api else { return nil }
        guard let deviceID = session?.authenticatedUser?.getDeviceId(on: api.network) else { return nil }
        return try? DiscoverDeviceIDDetails(deviceId: deviceID).encodedString()
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
