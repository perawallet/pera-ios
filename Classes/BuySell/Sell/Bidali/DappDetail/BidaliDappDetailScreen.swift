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

//   BidaliDappDetailScreen.swift

import Foundation
import WebKit

final class BidaliDappDetailScreen:
    DiscoverDappDetailScreen,
    SharedDataControllerObserver {
    override var allowsPullToRefresh: Bool {
        return false
    }

    private var messageHandlers: [MessageHandler] = [.paymentRequest, .openURLRequest]

    private var account: AccountHandle {
        didSet {
            let old = BidaliBalances(account: oldValue, network: api!.network)
            let new = BidaliBalances(account: account, network: api!.network)

            if old != new {
                updateBalance(new)
            }
        }
    }

    private lazy var jsonDecoder = JSONDecoder()

    private var bidaliConfiguration: BidaliConfiguration

    init(
        account: AccountHandle,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        var bidaliConfiguration = BidaliConfiguration(
            account: account,
            network: configuration.api!.network
        )
        self.bidaliConfiguration = bidaliConfiguration

        let dappParameters = DiscoverDappParamaters(
            name: nil,
            url: bidaliConfiguration.url,
            favorites: nil
        )
        super.init(dappParameters: dappParameters, configuration: configuration)

        self.sharedDataController.add(self)
    }

    deinit {
        sharedDataController.remove(self)
    }

    override func addRightBarButtonItems() {
        rightBarButtonItems = [ makeReloadBarButtonItem() ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addInitialScript()
        addMessageHandlers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        removeMessageHandlers() /// <todo> This should be removed after fixing retain cycle as discussed.
    }

    override func viewDidAppearAfterInteractiveDismiss() {
        super.viewDidAppearAfterInteractiveDismiss()

        cancelPayment()
    }
}

extension BidaliDappDetailScreen {
    private func makeReloadBarButtonItem() -> ALGBarButtonItem {
        ALGBarButtonItem(kind: .reload) {
            [unowned self] in
            self.reload()
        }
    }
}

extension BidaliDappDetailScreen {
    private func addInitialScript() {
        guard let script = makeInitialScript() else {
            assertionFailure("Failed to create initial script.")
            return
        }

        contentController.addUserScript(script)
    }

    private func makeInitialScript() -> WKUserScript? {
        guard let balances = try? bidaliConfiguration.balances.get() else {
            assertionFailure("Failed to decode account's balances.")
            return nil
        }

        let initialScript = """
  window.bidaliProvider = {
          key: '\(bidaliConfiguration.key)',
          name: '\(bidaliConfiguration.name)',
          paymentCurrencies: \(bidaliConfiguration.paymentCurrencies),
          balances: \(balances),
          onPaymentRequest: (paymentRequest) => {
            var payload = { request: paymentRequest };
            window.webkit.messageHandlers.\(MessageHandler.paymentRequest.rawValue).postMessage(JSON.stringify(payload));
          },
          openUrl: function (url) {
            var payload = { openURLRequest: { url } };
            window.webkit.messageHandlers.\(MessageHandler.openURLRequest.rawValue).postMessage(JSON.stringify(payload));
          }
        };
        true;
"""
        return WKUserScript(
            source: initialScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }
}

extension BidaliDappDetailScreen {
    enum MessageHandler: String {
        case paymentRequest
        case openURLRequest
    }

    private func addMessageHandlers() {
        messageHandlers.forEach {
            contentController.add(self, name: $0.rawValue)
        }
    }

    private func removeMessageHandlers() {
        messageHandlers.forEach {
            contentController.removeScriptMessageHandler(forName: $0.rawValue)
        }
    }
}

/// <note>: WKScriptMessageHandler
extension BidaliDappDetailScreen {
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        super.userContentController(userContentController, didReceive: message)

        guard let jsonString = message.body as? String,
              let jsonData = jsonString.data(using: .utf8) else {
            assertionFailure("Failed to encode the received `WKScriptMessage`.")
            return
        }

        if let bidaliPaymentRequestMessage = try? jsonDecoder.decode(BidaliPaymentRequestMessage.self, from: jsonData),
           let bidaliPaymentRequest = bidaliPaymentRequestMessage.request {
            openPaymentRequest(bidaliPaymentRequest)
            return
        }

        if let bidaliOpenURLRequestMessage = try? jsonDecoder.decode(BidaliOpenURLRequestMessage.self, from: jsonData),
           let bidaliOpenURLRequest = bidaliOpenURLRequestMessage.openURLRequest {
            open(bidaliOpenURLRequest.url)
            return
        }
    }
}

extension BidaliDappDetailScreen {
    private func openPaymentRequest(_ request: BidaliPaymentRequest) {
        guard let address = request.address,
              let amount = request.amount,
              let extraId = request.extraId,
              let `protocol` = request.protocol else {
            assertionFailure("Missing parameters on `BidaliPaymentRequest`.")
            return
        }

        let toAccount = Account(address: address, type: .standard)

        switch `protocol` {
        case .algorand:
            let draft = makeSendTransactionDraft(
                from: account.value,
                to: toAccount,
                asset: account.value.algo,
                amount: amount,
                extraId: extraId
            )
            openPaymentRequest(draft)
        case .usdcalgorand:
            if let asset = account.value[BidaliPaymentCurrency.usdcAssetID] {
                let draft = makeSendTransactionDraft(
                    from: account.value,
                    to: toAccount,
                    asset: asset,
                    amount: amount,
                    extraId: extraId
                )
                openPaymentRequest(draft)
            }
        case .usdtalgorand:
            if let asset = account.value[BidaliPaymentCurrency.usdtAssetID] {
                let draft = makeSendTransactionDraft(
                    from: account.value,
                    to: toAccount,
                    asset: asset,
                    amount: amount,
                    extraId: extraId
                )
                openPaymentRequest(draft)
            }
        case .testnetusdcalgorand:
            if let asset = account.value[BidaliPaymentCurrency.testnetUSDCAssetID] {
                let draft = makeSendTransactionDraft(
                    from: account.value,
                    to: toAccount,
                    asset: asset,
                    amount: amount,
                    extraId: extraId
                )
                openPaymentRequest(draft)
            }
        }
    }

    private func makeSendTransactionDraft(
        from: Account,
        to: Account,
        asset: Asset,
        amount: String,
        extraId: String
    ) -> SendTransactionDraft {
        let transactionMode: TransactionMode = asset.isAlgo ? .algo : .asset(asset)
        let draft = SendTransactionDraft(
            from: from,
            toAccount: to,
            amount: NSDecimalNumber(string: amount) as Decimal,
            transactionMode: transactionMode,
            lockedNote: extraId
        )
        return draft
    }

    private func openPaymentRequest(_ draft: SendTransactionDraft) {
        /// <todo> Cancel payment on close action and on all error cases.

        let controller = open(
            .sendTransactionPreview(draft: draft),
            by: .present
        ) as? SendTransactionPreviewScreen
        controller?.navigationController?.presentationController?.delegate = self
        controller?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            self.dismiss(animated: true)

            switch event {
            case .didCompleteTransaction: self.confirmPayment()
            default: break
            }
        }
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
    private func cancelPayment() {
        let script = "window.bidaliProvider.paymentCancelled();"
        webView.evaluateJavaScript(script)
    }

    private func confirmPayment() {
        let script = "window.bidaliProvider.paymentSent();"
        webView.evaluateJavaScript(script)
    }
}

extension BidaliDappDetailScreen {
    private func updateBalance(_ new: BidaliBalances) {
        guard let balances = try? new.toJSONString().get() else {
            assertionFailure("Failed to decode account's updated balances.")
            return
        }

        /// <todo> It's not working, maybe we're doing something wrong on our side or there is something wrong on Bidali side.
        let script = "window.bidaliProvider.balances = \(balances)"
        webView.evaluateJavaScript(script)
    }
}
