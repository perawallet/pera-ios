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
    func handleDiscoverInApp(_ inAppMessage: DiscoverInAppBrowserScriptMessage, _ message: WKScriptMessage) {
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
    
    func handleDiscoverExternal(_ inAppMessage: DiscoverExternalInAppBrowserScriptMessage, _ message: WKScriptMessage) {
        switch inAppMessage { case .peraconnect: handlePeraConnectAction(message) }
    }
    
    func handleDiscoverHome(_ inAppMessage: DiscoverHomeScriptMessage, _ message: WKScriptMessage) {
        switch inAppMessage {
        case .pushTokenDetailScreen:
            handleTokenDetailAction(message)
        case .swap, .handleTokenDetailActionButtonClick:
            handleTokenAction(message)
        }
    }
    
    func handlePublicWebview(_ inAppMessage: PublicWebviewInAppBrowserScreenMessage, _ message: WKScriptMessage) {
        switch inAppMessage {
        case .openSystemBrowser:
            handleOpenSystemBrowser(message)
        case .closeWebView, .onBackPressed:
            dismissScreen()
        case .pushWebView:
            guard
                let params = message.decode(PushWVParams.self),
                let url = URL(string: params.url)
            else { return }
            open(.publicWebview(url: url), by: .push)
        case .getPublicSettings:
            guard
                let theme = traitCollection.userInterfaceStyle == .dark ? "dark" : "light",
                let network = configuration.api?.network.rawValue,
                let language = Bundle.main.preferredLocalizations.first,
                let currency = try? sharedDataController.currency.primaryValue?.unwrap().name ?? ""
            else { return }
            handlePublicSettings(
                params: [
                    "theme": theme,
                    "network": network,
                    "language": language,
                    "currency": currency
                ]
            )
        case .logAnalyticsEvent:
            guard let params = message.decode(LogEventParams.self) else { return }
            analytics.track(params.name, payload: params.payload)
        }
    }
    
    func handleStaking(_ inAppMessage: StakingInAppBrowserScreenMessage, _ message: WKScriptMessage) {
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
    
    func handleFund(_ inAppMessage: FundInAppBrowserScriptMessage, _ message: WKScriptMessage) {
        switch inAppMessage {
        case .openSystemBrowser:
            handleOpenSystemBrowser(message)
        case .closeWebView, .onBackPressed:
            dismissScreen()
        case .pushWebView:
            guard
                let params = message.decode(PushWVParams.self),
                let url = URL(string: params.url)
            else { return }
            open(.publicWebview(url: url), by: .push)
        case .canOpenURI:
            handleCanOpenUri(message)
        case .openNativeURI:
            handleOpenNativeUri(message)
        case .notifyUser:
            handleNotifyUser(message)
        case .getAddresses:
            handleAddresses(message)
        case .getSettings, .getPublicSettings:
            handleSettings(inAppMessage, message)
        case .logAnalyticsEvent:
            guard let params = message.decode(LogEventParams.self) else { return }
            analytics.track(params.name, payload: params.payload)
        }
    }
    
    func handleCards(_ inAppMessage: CardsInAppBrowserScriptMessage, _ message: WKScriptMessage) {
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
    
    func handleBidali(_ inAppMessage: BidaliDappDetailScriptMessage, _ message: WKScriptMessage) {
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
    
    private func handleNotifyUser(_ message: WKScriptMessage) {
        guard let params = message.decode(NotifyParams.self) else { return }
        switch params.type {
        case .haptic: break
        case .sound: break
        case .message:
            guard let message = params.message else { return }
            if params.variant == "banner" {
                configuration.bannerController?.presentSuccessBanner(title: message)
            } else if params.variant == "toast" {
                configuration.bannerController?.presentInfoBanner(message)
            }
        }
    }
    
    private func handleAddresses(_ message: WKScriptMessage) {
        var addressesInfo = [[String: String]]()
        session?.authenticatedUser?.accounts.forEach { accountInformation in
            let account = Account(localAccount: accountInformation)
            let name = account.primaryDisplayName
            let address = account.address
            let type = account.authType
            addressesInfo.append(["name": name, "address": address, "type": type])
        }
        webView.evaluateJavaScript(
            Scripts.message(
                action: FundInAppBrowserScriptMessage.getAddresses.rawValue,
                payload: addressesInfo.description
            )
        )
    }
    
    private func handleSettings(_ inAppMessage: FundInAppBrowserScriptMessage, _ message: WKScriptMessage) {
        guard
            let theme = traitCollection.userInterfaceStyle == .dark ? "dark" : "light",
            let network = configuration.api?.network.rawValue,
            let language = Bundle.main.preferredLocalizations.first,
            let currency = try? sharedDataController.currency.primaryValue?.unwrap().name ?? ""
        else { return }
        var params = ["theme": theme, "network": network, "language": language, "currency": currency]
        
        guard inAppMessage == .getSettings else {
            handlePublicSettings(params: params)
            return
        }
        
        guard
            let deviceId = UIDevice.current.identifierForVendor?.uuidString,
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
            let appPackageName = Bundle.main.bundleIdentifier
        else { return }
        
        params["platform"] = "ios"
        params["appName"] = appName
        params["appPackageName"] = appPackageName
        params["appVersion"] = Bundle.main.version
        params["deviceId"] = deviceId
        params["deviceVersion"] = UIDevice.current.systemVersion
        params["deviceModel"] = UIDevice.current.model
        
        webView.evaluateJavaScript(
            Scripts.message(
                action: FundInAppBrowserScriptMessage.getSettings.rawValue,
                payload: params.description
            )
        )
    }
    
    private func handlePublicSettings(params: [String: String]) {
        webView.evaluateJavaScript(
            Scripts.message(
                action: FundInAppBrowserScriptMessage.getPublicSettings.rawValue,
                payload: params.description
            )
        )
    }
    
    private func handleCanOpenUri(_ message: WKScriptMessage) {
        guard
            let params = message.decode(URIParams.self),
            let uri = URL(string: params.uri)
        else { return }
        webView.evaluateJavaScript(
            Scripts.message(
                action: FundInAppBrowserScriptMessage.canOpenURI.rawValue,
                payload: UIApplication.shared.canOpenURL(uri).description
            )
        )
    }
    
    private func handleOpenNativeUri(_ message: WKScriptMessage) {
        guard
            let params = message.decode(URIParams.self),
            let uri = URL(string: params.uri)
        else { return }
        UIApplication.shared.open(uri)
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
