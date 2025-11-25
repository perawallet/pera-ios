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

//   DiscoverAssetDetailScreen.swift

import Foundation
import WebKit
import MacaroonUtils
import pera_wallet_core

final class DiscoverAssetDetailScreen: DiscoverInAppBrowserScreen {
    private let assetParameters: DiscoverAssetParameters
    
    override var handledMessages: [any InAppBrowserScriptMessage] {
        super.handledMessages + DiscoverAssetDetailScriptMessage.allCases
    }

    init(
        assetParameters: DiscoverAssetParameters,
        configuration: ViewControllerConfiguration
    ) {
        self.assetParameters = assetParameters
        super.init(
            destination: .assetDetail(assetParameters),
            configuration: configuration
        )
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = true
    }
    
    // MARK: - WKScriptMessageHandler
    
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if let inAppMessage = DiscoverAssetDetailScriptMessage(rawValue: message.name) {
            handleDiscoverAssetDetail(inAppMessage, message)
        }
        super.userContentController(userContentController, didReceive: message)
    }
}

enum DiscoverAssetDetailScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case handleTokenDetailActionButtonClick
}
