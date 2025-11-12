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

//   BidaliDappDetailScreen.swift

import Foundation
import MacaroonUtils
import WebKit
import pera_wallet_core

final class BidaliDappDetailScreen:
    DiscoverExternalInAppBrowserScreen,
    SharedDataControllerObserver {

    private var _account: AccountHandle

    override var account: AccountHandle {
        get { _account }
        set {
            let oldValue = _account
            _account = newValue
            updateBalancesIfNeeded(old: oldValue, new: newValue)
        }
    }
    
    override var handledMessages: [any InAppBrowserScriptMessage] {
        BidaliDappDetailScriptMessage.allCases
    }

    private let config: BidaliConfig

    init(
        account: AccountHandle,
        config: BidaliConfig,
        configuration: ViewControllerConfiguration
    ) {
        self._account = account
        self.config = config
        let url = URL(string: config.url)
        super.init(destination: .url(url), configuration: configuration)
        self.allowsPullToRefresh = false

        self.sharedDataController.add(self)
    }

    deinit {
        sharedDataController.remove(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addPaymentScript()
    }
    
    private func addPaymentScript() {
        guard let balancesJSONString = try? makeBalances(account).encodedString() else { return }
        userContentController.addUserScript(InAppBrowserScript.bidaliPayment(config: config, balance: balancesJSONString).userScript)
    }

    /// <note>
    /// In here, we're handling the cancel operation with assuming that confirm transaction screen is presented as modally.
    /// If presentation style changes we should handle the cancel the operation accordingly.
    override func viewDidAppearAfterInteractiveDismiss() {
        super.viewDidAppearAfterInteractiveDismiss()

        cancelPayment()
    }
}

extension BidaliDappDetailScreen {
    private func makeBalances(_ account: AccountHandle) -> BidaliBalances {
        switch api!.network {
        case .testnet:
            return makeBalancesForTestnet(account)
        case .mainnet:
            return makeBalancesForMainnet(account)
        }
    }

    private func makeBalancesForTestnet(_ account: AccountHandle) -> BidaliBalances {
        let network = api!.network
        let aRawAccount = account.value

        let algo = aRawAccount.algo.decimalAmount
        let usdc = aRawAccount.usdc(network)?.decimalAmount
        return [
            BidaliPaymentCurrencyProtocol.algo.getRawValue(in: network): algo.stringValue,
            BidaliPaymentCurrencyProtocol.usdc.getRawValue(in: network): usdc?.stringValue
        ]
    }

    private func makeBalancesForMainnet(_ account: AccountHandle) -> BidaliBalances {
        let network = api!.network
        let aRawAccount = account.value

        let algo = aRawAccount.algo.decimalAmount
        let usdc = aRawAccount.usdc(network)?.decimalAmount
        let usdt = aRawAccount.usdt(network)?.decimalAmount
        return [
            BidaliPaymentCurrencyProtocol.algo.getRawValue(in: network): algo.stringValue,
            BidaliPaymentCurrencyProtocol.usdc.getRawValue(in: network): usdc?.stringValue,
            BidaliPaymentCurrencyProtocol.usdt.getRawValue(in: network): usdt?.stringValue
        ]
    }
}

/// <note>: SharedDataControllerObserver
extension BidaliDappDetailScreen {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event,
           let upToDateAccount = sharedDataController.accountCollection[account.value.address],
           upToDateAccount.isAvailable {
            account = upToDateAccount
        }
    }
}

extension BidaliDappDetailScreen {
    private func updateBalancesIfNeeded(old: AccountHandle, new: AccountHandle) {
        if shouldUpdateBalances(old: old, new: new) {
            updateBalance(new)
        }
    }

    private func shouldUpdateBalances(old: AccountHandle, new: AccountHandle) -> Bool {
        if isAlgoBalanceChanged(old: old, new: new) {
            return true
        }

        if isUSDCBalanceChanged(old: old, new: new) {
            return true
        }

        if isUSDtBalanceChanged(old: old, new: new) {
            return true
        }

        return false
    }

    private func isAlgoBalanceChanged(old: AccountHandle, new: AccountHandle) -> Bool {
        let oldAlgo = old.value.algo
        let newAlgo = new.value.algo
        return oldAlgo.decimalAmount != newAlgo.decimalAmount
    }

    private func isUSDCBalanceChanged(old: AccountHandle, new: AccountHandle) -> Bool {
        let network = api!.network
        let oldUSDC = old.value.usdc(network)
        let newUSDC = new.value.usdc(network)
        return oldUSDC?.decimalAmount != newUSDC?.decimalAmount
    }

    private func isUSDtBalanceChanged(old: AccountHandle, new: AccountHandle) -> Bool {
        let network = api!.network
        let oldUSDt = old.value.usdt(network)
        let newUSDt = new.value.usdt(network)
        return oldUSDt?.decimalAmount != newUSDt?.decimalAmount
    }

    private func updateBalance(_ account: AccountHandle) {
        let balances = makeBalances(account)

        guard let balancesJSONString = try? balances.encodedString() else { return }

        let script = "window.bidaliProvider.balances = \(balancesJSONString)"
        webView.evaluateJavaScript(script)
    }
}

extension BidaliDappDetailScreen {
    private func presentGenericErrorBanner() {
        bannerController?.presentErrorBanner(
            title: String(localized: "title-error"),
            message: String(localized: "title-generic-error")
        )
    }
}

enum BidaliDappDetailScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case paymentRequest
    case openURLRequest
}

private extension Account {
    func asset(
        for currencyProtocol: BidaliPaymentCurrencyProtocol,
        network: ALGAPI.Network
    ) -> Asset? {
        switch currencyProtocol {
        case .algo: return algo
        case .usdc: return usdc(network)
        case .usdt: return usdt(network)
        default: return nil
        }
    }
}

private typealias BidaliBalances = [String: String?]
extension BidaliBalances: JSONModel  {}
