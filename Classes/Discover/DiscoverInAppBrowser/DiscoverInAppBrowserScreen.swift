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

//   DiscoverInAppBrowserScreen.swift

import Foundation
import UIKit
import WebKit

/// @abstract
/// DiscoverInAppBrowserScreen should be used for websites that created by Pera
/// It handles theme changes, some common logics on that websites.
class DiscoverInAppBrowserScreen<ScriptMessage>: InAppBrowserScreen<ScriptMessage>
where ScriptMessage: InAppBrowserScriptMessage {
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }

    private lazy var navigationScript = createNavigationScript()
    private lazy var peraConnectScript = createPeraConnectScript()
    
    var destination: DiscoverDestination {
        didSet { loadPeraURL() }
    }

    deinit {
        stopObservingNotifications()
    }

    init(
        destination: DiscoverDestination,
        configuration: ViewControllerConfiguration
    ) {
        self.destination = destination
        super.init(configuration: configuration)

        startObservingNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.updateTheme(self.traitCollection.userInterfaceStyle)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPeraURL()
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        updateTheme(userInterfaceStyle)
    }

    override func didPullToRefresh() {
        loadPeraURL()
    }

    override func createUserContentController() -> InAppBrowserUserContentController {
        let controller = super.createUserContentController()
        DiscoverInAppBrowserScriptMessage.allCases.forEach {
            controller.add(
                secureScriptMessageHandler: self,
                forMessage: $0
            )
        }
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
        guard let inAppMessage = DiscoverInAppBrowserScriptMessage(rawValue: message.name) else {
            super.userContentController(userContentController, didReceive: message)
            return
        }

        switch inAppMessage {
        case .pushNewScreen:
            handleNewScreenAction(message)
        case .requestDeviceID:
            handleDeviceIDRequest(message)
        case .pushDappViewerScreen:
            handleDappDetailAction(message)
        case .openSystemBrowser:
            handleOpenSystemBrowser(message)
        case .peraconnect:
            handlePeraConnectAction(message)
        case .requestAuthorizedAddresses:
            let handler = BrowserAuthorizedAddressEventHandler(sharedDataController: sharedDataController)
            handler.returnAuthorizedAccounts(message, in: webView, isAuthorizedAccountsOnly: false)
        }
    }
}

extension DiscoverInAppBrowserScreen {
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

extension DiscoverInAppBrowserScreen {
    private func generatePeraURL() -> URL? {
        DiscoverURLGenerator.generateURL(
            destination: destination,
            theme: traitCollection.userInterfaceStyle,
            session: session
        )
    }

    private func loadPeraURL() {
        let generatedUrl = generatePeraURL()
        load(url: generatedUrl)
    }
}

extension DiscoverInAppBrowserScreen {
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
    
    func createNavigationScript() -> WKUserScript {
        let navigationScript = """
!function(t){function e(t){setTimeout((function(){window.webkit.messageHandlers.navigation.postMessage(t)}),0)}function n(n){return function(){return e("other"),n.apply(t,arguments)}}t.pushState=n(t.pushState),t.replaceState=n(t.replaceState),window.addEventListener("popstate",(function(){e("backforward")}))}(window.history);
"""

        return WKUserScript(
            source: navigationScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }
    
    func createPeraConnectScript() -> WKUserScript {
        let peraConnectScript = """
function setupPeraConnectObserver(){const e=new MutationObserver(()=>{const t=document.getElementById("pera-wallet-connect-modal-wrapper"),e=document.getElementById("pera-wallet-redirect-modal-wrapper");if(e&&e.remove(),t){const o=t.getElementsByTagName("pera-wallet-connect-modal");let e="";if(o&&o[0]&&o[0].shadowRoot){const a=o[0].shadowRoot.querySelector("pera-wallet-modal-touch-screen-mode").shadowRoot.querySelector("#pera-wallet-connect-modal-touch-screen-mode-launch-pera-wallet-button");alert("LINK_ELEMENT_V1"+a),a&&(e=a.getAttribute("href"))}else{const r=t.getElementsByClassName("pera-wallet-connect-modal-touch-screen-mode__launch-pera-wallet-button");alert("LINK_ELEMENT_V0"+r),r&&(e=r[0].getAttribute("href"))}alert("WC_URI "+e),e&&(window.webkit.messageHandlers.\(DiscoverInAppBrowserScriptMessage.peraconnect.rawValue).postMessage(e),alert("Message sent to App"+e)),t.remove()}});e.disconnect(),e.observe(document.body,{childList:!0,subtree:!0})}setupPeraConnectObserver();
"""
        return WKUserScript(
            source: peraConnectScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }
}

extension DiscoverInAppBrowserScreen {
    private func handleNewScreenAction(_ message: WKScriptMessage) {
        if !isAcceptable(message) { return }
        guard let jsonString = message.body as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let params = try? DiscoverGenericParameters.decoded(jsonData) else { return }
        navigateToDiscoverGeneric(params)
    }

    private func navigateToDiscoverGeneric(_ params: DiscoverGenericParameters) {
        open(
            .discoverGeneric(params),
            by: .push
        )
    }

    private func handleDeviceIDRequest(_ message: WKScriptMessage) {
        if !isAcceptable(message) { return }
        guard let deviceIDDetails = makeDeviceIDDetails() else { return }

        let scriptString = "var message = '" + deviceIDDetails + "'; handleMessage(message);"
        self.webView.evaluateJavaScript(scriptString)
    }

    private func makeDeviceIDDetails() -> String? {
        guard let api else { return nil }
        guard let deviceID = session?.authenticatedUser?.getDeviceId(on: api.network) else { return nil }
        return try? DiscoverDeviceIDDetails(deviceId: deviceID).encodedString()
    }

    private func isAcceptable(_ message: WKScriptMessage) -> Bool {
        let frameInfo = message.frameInfo

        if !frameInfo.isMainFrame { return false }
        if frameInfo.request.url.unwrap(where: \.isPeraURL) == nil { return false }

        return true
    }
}

extension DiscoverInAppBrowserScreen {
    private func handleDappDetailAction(_ message: WKScriptMessage) {
        if !isAcceptable(message) { return }

        guard let jsonString = message.body as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let params = try? DiscoverDappParamaters.decoded(jsonData) else { return }
        navigateToDappDetail(params)
    }

    private func navigateToDappDetail(_ params: DiscoverDappParamaters) {
        let screen: Screen = .discoverDappDetail(params) {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .goBack:
                self.popScreen()
            case .addToFavorites(let dappDetails):
                self.addToFavorites(dappDetails)
            case .removeFromFavorites(let dappDetails):
                self.removeFromFavorites(dappDetails)
            }
        }

        open(
            screen,
            by: .push
        )
    }

    private func addToFavorites(_ dapp: DiscoverFavouriteDappDetails) {
        updateFavorites(dapp: dapp)
    }

    private func removeFromFavorites(_ dapp: DiscoverFavouriteDappDetails) {
        updateFavorites(dapp: dapp)
    }

    private func updateFavorites(dapp: DiscoverFavouriteDappDetails) {
        guard let dappDetailsString = try? dapp.encodedString() else {
            return
        }

        let scriptString = "var message = '" + dappDetailsString + "'; handleMessage(message);"
        self.webView.evaluateJavaScript(scriptString)
    }
}

extension DiscoverInAppBrowserScreen {
    private func handleOpenSystemBrowser(_ message: WKScriptMessage) {
        if !isAcceptable(message) { return }
      
        guard let jsonString = message.body as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let params = try? DiscoverGenericParameters.decoded(jsonData) else { return }

        openInBrowser(params.url)
    }
}

extension DiscoverInAppBrowserScreen {
    func handlePeraConnectAction(_ message: WKScriptMessage) {
        guard let jsonString = message.body as? String else { return }
        guard let url = URL(string: jsonString) else { return }
        guard let walletConnectURL = DeeplinkQR(url: url).walletConnectUrl() else { return }

        let src: DeeplinkSource = .walletConnectSessionRequestForDiscover(walletConnectURL)
        launchController.receive(deeplinkWithSource: src)
    }
}

extension UIUserInterfaceStyle {
    var peraRawValue: String {
        switch self {
        case .dark:
            return "dark-theme"
        default:
            return "light-theme"
        }
    }
}

enum DiscoverInAppBrowserScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case requestAuthorizedAddresses = "getAuthorizedAddresses"
    case pushNewScreen
    case requestDeviceID = "getDeviceId"
    case pushDappViewerScreen
    case openSystemBrowser
    case peraconnect
}
