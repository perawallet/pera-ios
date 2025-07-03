// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BrowserAuthorizedAddressEventHandler.swift

import Foundation
import UIKit
import WebKit

public struct BrowserAuthorizedAddressEventHandler {
    
    private let sharedDataController: SharedDataController
    
    init(sharedDataController: SharedDataController) {
        self.sharedDataController = sharedDataController
    }
    
    func returnAuthorizedAccounts(_ message: WKScriptMessage, in webView: WKWebView) {
        guard isAcceptableMessage(message),
              let cardAccountsBase64 = makeEncodedAccountDetails() else {
            return
        }
        
        let scriptString = "var message = '\(cardAccountsBase64)'; handleMessage(message);"
        webView.evaluateJavaScript(scriptString)
    }
}

private extension BrowserAuthorizedAddressEventHandler {
    func makeEncodedAccountDetails() -> String? {
        let sortedAccounts = sharedDataController.sortedAccounts(by: AccountDescendingTotalPortfolioValueAlgorithm(currency: sharedDataController.currency))
        let authorizedAccounts = sortedAccounts.filter { $0.value.authorization.isAuthorized }
        let accountsArray: [[String: String]] = authorizedAccounts.map {
            return [$0.value.address: $0.value.name ?? ""]
        }
        
        do {
            let jsonData = try JSONEncoder().encode(accountsArray)
            let accountsStringBase64 = jsonData.base64EncodedString()
            let accounts = try? CardsAccounts(accounts: accountsStringBase64).encodedString()
            return accounts
        } catch {
            return nil
        }
    }

    func isAcceptableMessage(_ message: WKScriptMessage) -> Bool {
        let frameInfo = message.frameInfo
        
        guard frameInfo.isMainFrame,
              frameInfo.request.url.unwrap(where: \.isPeraURL) != nil else {
            return false
        }
        
        return true
    }
}
