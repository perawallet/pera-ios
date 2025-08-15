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

import Scout
import MagpieHipo
import MagpieCore
@testable import pera_staging
@testable import pera_wallet_core


class MockSharedDataController: SharedDataController, Mockable {
    
    var mock = Mock()
    
    var assetDetailCollection: AssetDetailCollection {
        get {
            mock.get.assetDetailCollection
        }
        set {
            //ignore
        }
    }
    
    var selectedAccountSortingAlgorithm: (any AccountSortingAlgorithm)? {
        get {
            mock.get.selectedAccountSortingAlgorithm
        }
        set {
            //ignore
        }
    }
    
    var accountSortingAlgorithms: [any AccountSortingAlgorithm] {
        get {
            mock.get.accountSortingAlgorithms
        }
        set {
            //ignore
        }
    }
    
    var selectedAccountAssetSortingAlgorithm: (any AccountAssetSortingAlgorithm)? {
        get {
            mock.get.selectedAccountAssetSortingAlgorithm
        }
        set {
            //ignore
        }
    }
    
    var accountAssetSortingAlgorithms: [any AccountAssetSortingAlgorithm] {
        get {
            mock.get.accountAssetSortingAlgorithms
        }
        set {
            //ignore
        }
    }
    
    var selectedCollectibleSortingAlgorithm: (any CollectibleSortingAlgorithm)? {
        get {
            mock.get.selectedCollectibleSortingAlgorithm
        }
        set {
            //ignore
        }
    }
    
    var collectibleSortingAlgorithms: [any CollectibleSortingAlgorithm] {
        get {
            mock.get.collectibleSortingAlgorithms
        }
        set {
            //ignore
        }
    }
    
    var accountCollection: AccountCollection {
        get {
            mock.get.accountCollection
        }
        set {
            //ignore
        }
    }
    
    var currency: any CurrencyProvider {
        get {
            mock.get.currency
        }
        set {
            //ignore
        }
    }
    
    var blockchainUpdatesMonitor: BlockchainUpdatesMonitor {
        get {
            mock.get.blockchainUpdatesMonitor
        }
        set {
            //ignore
        }
    }
    
    var currentInboxRequestCount: Int {
        get {
            mock.get.currentInboxRequestCount
        }
        set {
            //ignore
        }
    }
    
    var isAvailable: Bool {
        get {
            mock.get.isAvailable
        }
        set {
            //ignore
        }
    }
    
    var isPollingAvailable: Bool {
        get {
            mock.get.isPollingAvailable
        }
        set {
            //ignore
        }
    }
    
    func initialize() {
        try! mock.call.initialize()
    }
    
    func startPolling() {
        try! mock.call.startPolling()
    }
    
    func stopPolling() {
        try! mock.call.stopPolling()
    }
    
    func resetPolling() {
        try! mock.call.resetPolling()
    }
    
    func resetPollingAfterRemoving(_ account: Account) {
        try! mock.call.resetPollingAfterRemoving(account)
    }
    
    func resetPollingAfterPreferredCurrencyWasChanged() {
        try! mock.call.resetPollingAfterPreferredCurrencyWasChanged()
    }
    
    func getPreferredOrderForNewAccount() -> Int {
        return try! mock.call.getPreferredOrderForNewAccount() as! Int
    }
    
    func hasOptedIn(assetID: AssetID, for account: Account) -> OptInStatus {
        return try! mock.call.hasOptedIn(assetID: assetID, for: account) as! OptInStatus
    }
    
    func hasOptedOut(assetID: AssetID, for account: Account) -> OptOutStatus {
        return try! mock.call.hasOptedOut(assetID: assetID, for: account) as! OptOutStatus
    }
    
    func add(_ observer: any SharedDataControllerObserver) {
        try! mock.call.add(observer)
    }
    
    func remove(_ observer: any SharedDataControllerObserver) {
        try! mock.call.remove(observer)
    }
    
    func getTransactionParams(isCacheEnabled: Bool, _ handler: @escaping (Result<TransactionParams, MagpieHipo.HIPNetworkError<MagpieCore.NoAPIModel>>) -> Void) {
        try! mock.call.getTransactionParams(isCacheEnabled: isCacheEnabled, handler: handler)
    }
    
    func getTransactionParams(_ handler: @escaping (Result<TransactionParams, MagpieHipo.HIPNetworkError<MagpieCore.NoAPIModel>>) -> Void) {
        try! mock.call.getTransactionParams(handler)
    }
    
    func rekeyedAccounts(of account: Account) -> [AccountHandle] {
        return try! mock.call.rekeyedAccounts(account: account) as! [AccountHandle]
    }
    
    func authAccount(of account: Account) -> AccountHandle? {
        return try! mock.call.authAccount(account: account) as! AccountHandle?
    }
    
    func determineAccountAuthorization(of account: Account) -> AccountAuthorization {
        return try! mock.call.determineAccountAuthorization(account: account) as! AccountAuthorization
    }
}
