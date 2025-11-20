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

//   InAppBrowserHelpers.swift

import WebKit
import pera_wallet_core

extension InAppBrowserScreen {
    func parseWebViewMessageV1(_ message: WKScriptMessage) {
        switch message.name {
        case let name where DiscoverAssetDetailScriptMessage(rawValue: name) != nil:
            guard let inAppMessage = DiscoverAssetDetailScriptMessage(rawValue: name) else { return }
            handleDiscoverAssetDetail(inAppMessage, message)
        case let name where DiscoverExternalInAppBrowserScriptMessage(rawValue: name) != nil:
            guard let inAppMessage = DiscoverExternalInAppBrowserScriptMessage(rawValue: name) else { return }
            handleDiscoverExternal(inAppMessage, message)
        case let name where DiscoverHomeScriptMessage(rawValue: name) != nil:
            guard let inAppMessage = DiscoverHomeScriptMessage(rawValue: name) else { return }
            handleDiscoverHome(inAppMessage, message)
        case let name where DiscoverInAppBrowserScriptMessage(rawValue: name) != nil:
            guard let inAppMessage = DiscoverInAppBrowserScriptMessage(rawValue: name) else { return }
            handleDiscoverInApp(inAppMessage, message)
        case let name where StakingInAppBrowserScreenMessage(rawValue: name) != nil:
            guard let inAppMessage = StakingInAppBrowserScreenMessage(rawValue: name) else { return }
            handleStaking(inAppMessage, message)
        case let name where CardsInAppBrowserScriptMessage(rawValue: name) != nil:
            guard let inAppMessage = CardsInAppBrowserScriptMessage(rawValue: name) else { return }
            handleCards(inAppMessage, message)
        case let name where BidaliDappDetailScriptMessage(rawValue: name) != nil:
            guard let inAppMessage = BidaliDappDetailScriptMessage(rawValue: name) else { return }
            handleBidali(inAppMessage, message)
        default: break
        }
    }
    
    func parseWebViewMessageV2(_ message: WKScriptMessage) {
        guard let scriptMessage = WebViewV2Message(rawValue: message.name) else { return }
        print("---message: \(scriptMessage.rawValue)")
        
        switch scriptMessage {
        case .pushWebView:
            guard
                let params = message.decode(PushWVParams.self),
                let url = URL(string: params.url)
            else { return }
            open(url)
        case .openSystemBrowser:
            guard
                let params = message.decode(URLParams.self),
                let url = URL(string: params.url)
            else { return }
            openInBrowser(url)
        case .canOpenURI:
            guard
                let params = message.decode(URIParams.self),
                let uri = URL(string: params.uri)
            else { return }
            webView.evaluateJavaScript(
                Scripts.message(
                    action: scriptMessage.rawValue,
                    payload: UIApplication.shared.canOpenURL(uri).description
                )
            )
        case .openNativeURI:
            guard
                let params = message.decode(URIParams.self),
                let uri = URL(string: params.uri)
            else { return }
            UIApplication.shared.open(uri)
        case .notifyUser:
            guard let params = message.decode(NotifyParams.self) else { return }
            print("---params: \(params)")
        case .getAddresses:
            break
        case .getSettings:
            break
        case .getPublicSettings:
            break
        case .onBackPressed:
            break
        case .logAnalyticsEvent:
            guard let params = message.decode(LogEventParams.self) else { return }
            print("---params: \(params)")
        case .closeWebView:
            break
        }
    }
    
    private func handleDiscoverInApp(_ inAppMessage: DiscoverInAppBrowserScriptMessage, _ message: WKScriptMessage) {
        switch inAppMessage {
        case .requestAuthorizedAddresses:
            handleRequestAuthorizedAddresses(message, isAuthorizedAccountsOnly: false)
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
        }
    }
    
    func handleDiscoverAssetDetail(_ inAppMessage: DiscoverAssetDetailScriptMessage, _ message: WKScriptMessage) {
        switch inAppMessage { case .handleTokenDetailActionButtonClick: handleTokenAction(message) }
    }
    
    private func handleDiscoverExternal(_ inAppMessage: DiscoverExternalInAppBrowserScriptMessage, _ message: WKScriptMessage) {
        switch inAppMessage { case .peraconnect: handlePeraConnectAction(message) }
    }
    
    private func handleDiscoverHome(_ inAppMessage: DiscoverHomeScriptMessage, _ message: WKScriptMessage) {
        switch inAppMessage {
        case .pushTokenDetailScreen:
            handleTokenDetailAction(message)
        case .swap, .handleTokenDetailActionButtonClick:
            handleTokenAction(message)
        }
    }
    
    private func handleStaking(_ inAppMessage: StakingInAppBrowserScreenMessage, _ message: WKScriptMessage) {
        switch inAppMessage {
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
    
    private func handleCards(_ inAppMessage: CardsInAppBrowserScriptMessage, _ message: WKScriptMessage) {
        switch inAppMessage {
        case .requestAuthorizedAddresses:
            handleRequestAuthorizedAddresses(message, isAuthorizedAccountsOnly: true)
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
    
    private func handleBidali(_ inAppMessage: BidaliDappDetailScriptMessage, _ message: WKScriptMessage) {
        switch inAppMessage {
        case .paymentRequest:
            handlePaymentRequestAction(message)
        case .openURLRequest:
            handleOpenURLRequestAction(message)
        }
    }
    
    private func handlePeraConnectAction(_ message: WKScriptMessage) {
        guard
            let jsonString = message.body as? String,
            let url = URL(string: jsonString),
            let walletConnectURL = DeeplinkQR(url: url).walletConnectUrl()
        else { return }

        let src: DeeplinkSource = .walletConnectSessionRequestForDiscover(walletConnectURL)
        launchController.receive(deeplinkWithSource: src)
    }
    
    private func handleTokenDetailAction(_ message: WKScriptMessage) {
        guard let params = message.decode(DiscoverAssetParameters.self) else { return }
        navigateToAssetDetail(params)
    }
    
    private func navigateToAssetDetail(_ params: DiscoverAssetParameters) {
        open(
            .discoverAssetDetail(params),
            by: .push
        )
    }
    
    private func handleTokenAction(_ message: WKScriptMessage) {
        guard let params = message.decode(DiscoverSwapParameters.self) else { return }

        switch params.action {
        case .buyAlgo:
           navigateToBuyAlgo()
        default:
            navigateToSwap(with: params)
        }

        sendAnalyticsEvent(with: params)
    }
    
    private func navigateToBuyAlgo() {
        meldFlowCoordinator.launch()
    }
    
    private func navigateToSwap(with parameters: DiscoverSwapParameters) {
        guard let rootViewController = UIApplication.shared.rootViewController() else { return }
        let draft = SwapAssetFlowDraft()
        if let assetInID = parameters.assetIn {
            draft.assetInID = assetInID
        }
        if let assetOutID = parameters.assetOut {
            draft.assetOutID = assetOutID
        }
        
        rootViewController.launch(tab: .swap, with: draft)
    }
    
    private func handleDeviceIDRequest(_ message: WKScriptMessage) {
        if !message.isAcceptable { return }
        guard let deviceIDDetails = makeDeviceIDDetails() else { return }
        
        webView.sendMessage(deviceIDDetails)
    }
    
    private func makeDeviceIDDetails() -> String? {
        guard let api else { return nil }
        guard let deviceID = session?.authenticatedUser?.getDeviceId(on: api.network) else { return nil }
        return try? DiscoverDeviceIDDetails(deviceId: deviceID).encodedString()
    }
    
    private func handleOpenSystemBrowser(_ message: WKScriptMessage) {
        if !message.isAcceptable { return }
        guard let params = message.decode(DiscoverGenericParameters.self) else { return }
        openInBrowser(params.url)
    }
    
    private func handleRequestAuthorizedAddresses(_ message: WKScriptMessage, isAuthorizedAccountsOnly: Bool) {
        let handler = BrowserAuthorizedAddressEventHandler(sharedDataController: sharedDataController)
        handler.returnAuthorizedAccounts(message, in: webView, isAuthorizedAccountsOnly: isAuthorizedAccountsOnly)
    }
    
    private func handleDappDetailAction(_ message: WKScriptMessage) {
        if !message.isAcceptable { return }
        guard let params = message.decode(DiscoverDappParamaters.self) else { return }
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
        webView.sendMessage(dappDetailsString)
    }
    
    private func handleNewScreenAction(_ message: WKScriptMessage) {
        if !message.isAcceptable { return }
        guard let params = message.decode(DiscoverGenericParameters.self) else { return }
        navigateToDiscoverGeneric(params)
    }

    private func navigateToDiscoverGeneric(_ params: DiscoverGenericParameters) {
        open(
            .discoverGeneric(params),
            by: .push
        )
    }
    
    private func handlePaymentRequestAction(_ message: WKScriptMessage) {
        guard let params = message.decode(BidaliPaymentParameters.self),
              let paymentRequest = params.data else {
            presentGenericErrorBanner()
            return
        }

        openPaymentRequest(paymentRequest)
    }

    private func openPaymentRequest(_ request: BidaliPaymentRequest) {
        guard let address = request.address,
              let amount = request.amount,
              let extraId = request.extraID,
              let currencyProtocol = request.currencyProtocol,
              let account
        else {
            presentGenericErrorBanner()
            return
        }

        let asset = account.value.asset(for: currencyProtocol, network: api!.network)

        guard let asset else {
            presentGenericErrorBanner()
            return
        }

        let draft = makeSendTransactionDraft(
            from: account.value,
            to: Account(address: address),
            asset: asset,
            amount: amount,
            extraId: extraId
        )
        openPaymentRequest(draft)
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
        let controller = open(
            .sendTransactionPreview(draft: draft),
            by: .present
        ) as? SendTransactionPreviewScreen
        controller?.navigationController?.presentationController?.delegate = self
        controller?.eventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .didCompleteTransaction:
                confirmPayment()
            case .didPerformDismiss:
                cancelPayment()
            default:
                break
            }
        }
    }
    
    func cancelPayment() {
        webView.sendBidaliEvent("paymentCancelled")
    }

    private func confirmPayment() {
        webView.sendBidaliEvent("paymentSent")
    }
    
    private func handleOpenURLRequestAction(_ message: WKScriptMessage) {
        guard let params = message.decode(BidaliOpenURLParameters.self),
              let openURLRequest = params.data else {
            presentGenericErrorBanner()
            return
        }

        openOpenURLRequest(openURLRequest)
    }

    private func openOpenURLRequest(_ request: BidaliOpenURLRequest) {
        guard let url = request.url.toURL() else {
            presentGenericErrorBanner()
            return
        }

        open(url)
    }
    
    private func presentGenericErrorBanner() {
        bannerController?.presentErrorBanner(
            title: String(localized: "title-error"),
            message: String(localized: "title-generic-error")
        )
    }
    
    private func sendAnalyticsEvent(with parameters: DiscoverSwapParameters) {
        let assetInID = parameters.assetIn
        let assetOutID = parameters.assetOut

        switch parameters.action {
        case .buyAlgo:
            self.analytics.track(.buyAssetFromDiscover(assetOutID: 0, assetInID: nil))
        case .swapFromAlgo:
            self.analytics.track(.sellAssetFromDiscover(assetOutID: assetOutID, assetInID: 0))
        case .swapToAsset:
            guard let assetOutID else { return }
            self.analytics.track(.buyAssetFromDiscover(assetOutID: assetOutID, assetInID: assetInID))
        case .swapFromAsset:
            self.analytics.track(.sellAssetFromDiscover(assetOutID: assetOutID, assetInID: assetInID))
        }
    }
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
