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

//   StakingInAppBrowserScreen.swift

import Foundation
import UIKit
import WebKit

class StakingInAppBrowserScreen<ScriptMessage>: InAppBrowserScreen<ScriptMessage>
where ScriptMessage: InAppBrowserScriptMessage {
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }

    var destination: StakingDestination {
        didSet { loadStakingURL() }
    }

    private lazy var navigationScript = createNavigationScript()
    private lazy var peraConnectScript = createPeraConnectScript()
    
    init(
        destination: StakingDestination,
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
        loadStakingURL()
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
        loadStakingURL()
    }

    override func createUserContentController() -> InAppBrowserUserContentController {
        let controller = super.createUserContentController()
        StakingInAppBrowserScreenMessage.allCases.forEach {
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
        let inAppMessage = StakingInAppBrowserScreenMessage(rawValue: message.name)
        switch inAppMessage {
        case .none:
            super.userContentController(
                userContentController,
                didReceive: message
            )
        case .openSystemBrowser:
            handleOpenSystemBrowser(message)
        case .closeWebView:
            dismissScreen()
        case .peraconnect:
            handlePeraConnectAction(message)
        case .requestDeviceID:
            handleDeviceIDRequest(message)
        case .openDappWebview:
            handleDappDetailAction(message)
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

extension StakingInAppBrowserScreen {
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


extension StakingInAppBrowserScreen {
    private func isAcceptableMessage(_ message: WKScriptMessage) -> Bool {
        let frameInfo = message.frameInfo

        if !frameInfo.isMainFrame { return false }
        if frameInfo.request.url.unwrap(where: \.isPeraURL) == nil { return false }

        return true
    }
}

extension StakingInAppBrowserScreen {
    private func handleOpenSystemBrowser(_ message: WKScriptMessage) {
        if !isAcceptableMessage(message) { return }
      
        guard let jsonString = message.body as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let params = try? DiscoverGenericParameters.decoded(jsonData) else { return }

        openInBrowser(params.url)
    }
}

extension StakingInAppBrowserScreen {
    private func handlePeraConnectAction(_ message: WKScriptMessage) {
        guard let jsonString = message.body as? String else { return }
        guard let url = URL(string: jsonString) else { return }
        guard let walletConnectURL = DeeplinkQR(url: url).walletConnectUrl() else { return }

        let src: DeeplinkSource = .walletConnectSessionRequestForDiscover(walletConnectURL)
        launchController.receive(deeplinkWithSource: src)
    }
}

extension StakingInAppBrowserScreen {
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

extension StakingInAppBrowserScreen {
    private func handleDappDetailAction(_ message: WKScriptMessage) {
        if !isAcceptableMessage(message) { return }

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
                self.findVisibleScreen().dismissScreen()
            default:
                break
            }
        }

        open(
            screen,
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
        )
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
