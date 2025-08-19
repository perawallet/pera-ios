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

//   BrowserAuthorizedAddressEventHandler.swift

import Foundation
import UIKit
import WebKit

public struct BrowserAuthorizedAddressEventHandler {
    
    private let sharedDataController: SharedDataController
    
    init(sharedDataController: SharedDataController) {
        self.sharedDataController = sharedDataController
    }
    
    func returnAuthorizedAccounts(_ message: WKScriptMessage, in webView: WKWebView, isAuthorizedAccountsOnly: Bool) {
        guard isAcceptableMessage(message),
              let cardAccountsBase64 = makeEncodedAccountDetails(isAuthorizedAccountsOnly) else {
            return
        }
        
        let scriptString = "var message = '\(cardAccountsBase64)'; handleMessage(message);"
        webView.evaluateJavaScript(scriptString)
    }
}

private extension BrowserAuthorizedAddressEventHandler {
    func makeEncodedAccountDetails(_ isAuthorizedAccountsOnly: Bool) -> String? {
        let sortedAccounts = sharedDataController.sortedAccounts(by: AccountDescendingTotalPortfolioValueAlgorithm(currency: sharedDataController.currency))
        let accounts = sortedAccounts.filter { account in
            if isAuthorizedAccountsOnly {
                return account.value.authorization.isAuthorized
            }
            
            return true
        }
        
        if isAuthorizedAccountsOnly {
            return returnOnlyAuthorizedAccounts(accounts)
        }
        
        return returnAllAccounts(accounts)
    }
    
    private func returnOnlyAuthorizedAccounts(_ accounts: [AccountHandle]) -> String? {
        let accountsArray: [[String: String]] = accounts.map {
            return [$0.value.address: $0.value.name ?? ""]
        }
        
        return returnAccounts(accountsArray)
    }
    
    private func returnAllAccounts(_ accounts: [AccountHandle]) -> String? {
        struct AccountItem: Codable {
            let address: String
            let name: String
            let type: String
        }
        
        let accountsArray: [AccountItem] = accounts.map { account in
            return AccountItem(
                address: account.value.address,
                name: account.value.primaryDisplayName,
                type: getAccountAuthValue(account.value)
            )
        }

        return returnAccounts(accountsArray)
    }
    
    private func returnAccounts(_ values: Encodable) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(values)
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
    
    func getAccountAuthValue(_ account: Account) -> String {
        if account.isHDAccount {
            return "HdKey"
        }
        
        if account.isWatchAccount {
            return "NoAuth"
        }
        
        if account.authorization.isRekeyedToNoAuthInLocal {
            return "Rekeyed"
        }
        
        if account.authorization.isRekeyed {
            return "RekeyedAuth"
        }
        
        if account.authorization.isLedger {
            return "LedgerBle"
        }
        
        if account.authorization.isStandard {
            return "Algo25"
        }
        
        if account.authorization.isNoAuth {
            return "NoAuth"
        }
        
        return ""
    }
}
