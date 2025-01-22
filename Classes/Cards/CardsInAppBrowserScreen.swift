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

//   CardsInAppBrowserScreen.swift

import Foundation
import UIKit
import WebKit

class CardsInAppBrowserScreen<ScriptMessage>: InAppBrowserScreen<ScriptMessage>
where ScriptMessage: InAppBrowserScriptMessage {
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }

    var destination: CardsDestination {
        didSet { loadCardsURL() }
    }

    private lazy var navigationScript = createNavigationScript()
    private lazy var peraConnectScript = createPeraConnectScript()
    
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
        /// App listens this script in order to catch html5 navigation process
        controller.addUserScript(navigationScript)
        controller.addUserScript(peraConnectScript)
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
            returnAuthorizedAccounts(message)
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

extension CardsInAppBrowserScreen {
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

extension CardsInAppBrowserScreen {
    private func generatePeraURL() -> URL? {
        CardsURLGenerator.generateURL(
            destination: destination,
            theme: traitCollection.userInterfaceStyle,
            session: session,
            network: api?.network ?? .mainnet
        )
    }

    private func loadCardsURL() {
        let generatedUrl = generatePeraURL()
        load(url: generatedUrl)
    }
}

extension CardsInAppBrowserScreen {
    private func updateTheme(_ style: UIUserInterfaceStyle) {
        let theme = style.peraRawValue
        let script = "updateTheme('\(theme)')"
        webView.evaluateJavaScript(script)
    }
}

extension CardsInAppBrowserScreen {
    private func createNavigationScript() -> WKUserScript {
        let navigationScript = """
!function(t){function e(t){setTimeout((function(){window.webkit.messageHandlers.navigation.postMessage(t)}),0)}function n(n){return function(){return e("other"),n.apply(t,arguments)}}t.pushState=n(t.pushState),t.replaceState=n(t.replaceState),window.addEventListener("popstate",(function(){e("backforward")}))}(window.history);
"""

        return WKUserScript(
            source: navigationScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }

    private func createPeraConnectScript() -> WKUserScript {
        let peraConnectScript = """
function setupPeraConnectObserver(){const e=new MutationObserver(()=>{const t=document.getElementById("pera-wallet-connect-modal-wrapper"),e=document.getElementById("pera-wallet-redirect-modal-wrapper");if(e&&e.remove(),t){const o=t.getElementsByTagName("pera-wallet-connect-modal");let e="";if(o&&o[0]&&o[0].shadowRoot){const a=o[0].shadowRoot.querySelector("pera-wallet-modal-touch-screen-mode").shadowRoot.querySelector("#pera-wallet-connect-modal-touch-screen-mode-launch-pera-wallet-button");alert("LINK_ELEMENT_V1"+a),a&&(e=a.getAttribute("href"))}else{const r=t.getElementsByClassName("pera-wallet-connect-modal-touch-screen-mode__launch-pera-wallet-button");alert("LINK_ELEMENT_V0"+r),r&&(e=r[0].getAttribute("href"))}alert("WC_URI "+e),e&&(window.webkit.messageHandlers.\(DiscoverExternalInAppBrowserScriptMessage.peraconnect.rawValue).postMessage(e),alert("Message sent to App"+e)),t.remove()}});e.disconnect(),e.observe(document.body,{childList:!0,subtree:!0})}setupPeraConnectObserver();
"""
        return WKUserScript(
            source: peraConnectScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }
}


extension CardsInAppBrowserScreen {

    private func returnAuthorizedAccounts(_ message: WKScriptMessage) {
        if !isAcceptableMessage(message) { return }
        guard let cardAccountsBase64 = makeEncodedAccountDetails() else { return }
        let scriptString = "var message = '\(cardAccountsBase64)'; handleMessage(message);"
        self.webView.evaluateJavaScript(scriptString)
    }
    
    private func makeEncodedAccountDetails() -> String? {
        let sortedAccounts = sharedDataController.sortedAccounts(by: AccountDescendingTotalPortfolioValueAlgorithm(currency: sharedDataController.currency))
        let authorizedAccounts = sortedAccounts.filter { $0.value.authorization.isAuthorized }
        let accountsArray: [[String: String]] = authorizedAccounts.compactMap {
            return [$0.value.address: $0.value.name ?? ""]
        }
        do {
            let jsonData = try JSONEncoder().encode(accountsArray)
            let accountsStringBase64 = jsonData.base64EncodedString()
            let cardsAccountsModel = try? CardsAccounts(accounts: accountsStringBase64).encodedString()
            return cardsAccountsModel
        } catch {
            return nil
        }
    }

    private func isAcceptableMessage(_ message: WKScriptMessage) -> Bool {
        let frameInfo = message.frameInfo

        if !frameInfo.isMainFrame { return false }
        if frameInfo.request.url.unwrap(where: \.isPeraURL) == nil { return false }

        return true
    }
}

extension CardsInAppBrowserScreen {
    private func handleOpenSystemBrowser(_ message: WKScriptMessage) {
        if !isAcceptableMessage(message) { return }
      
        guard let jsonString = message.body as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let params = try? DiscoverGenericParameters.decoded(jsonData) else { return }

        openInBrowser(params.url)
    }
}

extension CardsInAppBrowserScreen {
    private func handlePeraConnectAction(_ message: WKScriptMessage) {
        guard let jsonString = message.body as? String else { return }
        guard let url = URL(string: jsonString) else { return }
        guard let walletConnectURL = DeeplinkQR(url: url).walletConnectUrl() else { return }

        let src: DeeplinkSource = .walletConnectSessionRequestForDiscover(walletConnectURL)
        launchController.receive(deeplinkWithSource: src)
    }
}

extension CardsInAppBrowserScreen {
    private func handleDeviceIDRequest(_ message: WKScriptMessage) {
        if !isAcceptableMessage(message) { return }
        guard let deviceIDDetails = makeDeviceIDDetails() else { return }

        let scriptString = "var message = '" + deviceIDDetails + "'; handleMessage(message);"
        self.webView.evaluateJavaScript(scriptString)
    }

    private func makeDeviceIDDetails() -> String? {
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
