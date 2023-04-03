// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   DiscoverGenericScreen.swift

import Foundation
import UIKit
import WebKit

final class DiscoverGenericScreen: DiscoverInAppBrowserScreen<DiscoverGenericScriptMessage> {
    init(
        params: DiscoverGenericParameters,
        configuration: ViewControllerConfiguration
    ) {
        super.init(
            destination: .generic(params),
            configuration: configuration
        )
    }

    /// <mark>
    /// WKScriptMessageHandler
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        let inAppMessage = DiscoverGenericScriptMessage(rawValue: message.name)

        switch inAppMessage {
        case .none:
            super.userContentController(
                userContentController,
                didReceive: message
            )
        case .pushDappViewerScreen:
            handleDappDetailAction(message)
        }
    }
}

extension DiscoverGenericScreen {
    private func isAcceptable(_ message: WKScriptMessage) -> Bool {
        let frameInfo = message.frameInfo

        if !frameInfo.isMainFrame { return false }
        if frameInfo.request.url.unwrap(where: \.isPeraURL) == nil { return false }

        return true
    }

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

enum DiscoverGenericScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case pushDappViewerScreen
}
