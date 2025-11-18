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

//   InAppBrowserScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils
import WebKit
import pera_wallet_core

class InAppBrowserScreen:
    BaseViewController,
    WKNavigationDelegate,
    NotificationObserver,
    WKUIDelegate,
    WKScriptMessageHandler
{
    
    // MARK: - Properties
    
    var allowsPullToRefresh: Bool = true
    var notificationObservations: [NSObjectProtocol] = []
    private var isViewLayoutLoaded = false
    
    private(set) lazy var webView: WKWebView = createWebView()
    private(set) lazy var noContentView = InAppBrowserNoContentView(theme.noContent)
    private(set) lazy var userContentController = createUserContentController()
    
    private let socialMediaDeeplinkParser = DiscoverSocialMediaRouter()
    private let theme = InAppBrowserScreenTheme()
    
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: SwapDataLocalStore(),
        configuration: configuration,
        presentingScreen: self
    )
    
    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )

    var extraUserScripts: [InAppBrowserScript] { [] }
    var handledMessages: [any InAppBrowserScriptMessage] { [] }
    var account: AccountHandle? { nil }

    private(set) var userAgent: String? = nil
    private var sourceURL: URL?
    private var lastURL: URL? { webView.url ?? sourceURL }
    
    enum WebViewV2Message: String, InAppBrowserScriptMessage {
        case pushWebView
        case openSystemBrowser
        case canOpenUri
        case openNativeURI
        case notifyUser
        case getAddresses
        case getSettings
        case getPublicSettings
        case onBackPressed
        case logAnalyticsEvent
        case closeWebView
    }

    // MARK: - Initialisers
    
    deinit {
        userContentController.removeAllScriptMessageHandlers()
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// To prevent the standalone usage
        if type(of: self) == InAppBrowserScreen.self {
            fatalError("InAppBrowserScreen is abstract — instantiate a subclass instead.")
        }
        
        addUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(
            name: .inAppBrowserAppeared,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(
            name: .inAppBrowserDisappeared,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            updateUIForLoading()
            isViewLayoutLoaded = true
        }
    }
    
    // MARK: - Setups
    
    func load(url: URL?) {
        guard let url = url else {
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        webView.load(request)

        sourceURL = url
    }

    func createWebView() -> WKWebView {
        let configuration = createWebViewConfiguration()
        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false
        return webView
    }

    func createWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.userContentController = userContentController
        configuration.preferences = WKPreferences()
        return configuration
    }

    private func createUserContentController() -> InAppBrowserUserContentController {
        let controller = InAppBrowserUserContentController()
        controller.addUserScript(InAppBrowserScript.selection.userScript)

        extraUserScripts.forEach { controller.addUserScript($0.userScript) }
        handledMessages.forEach { controller.add(secureScriptMessageHandler: self, forName: $0.rawValue) }
        
        return controller
    }
    
    // MARK: - UI functions
    
    private func addUI() {
        addBackground()
        addWebView()
        addNoContent()
    }

    private func updateUI(for state: InAppBrowserNoContentView.State) {
        let isNoContentVisible = !noContentView.isHidden

        noContentView.setState(
            state,
            animated: isViewAppeared && isNoContentVisible
        )

        if isNoContentVisible { return }

        updateUI(
            from: webView,
            to: noContentView,
            animated: isViewAppeared
        )
    }

    private typealias UpdateUICompletion = (Bool) -> Void
    private func updateUI(
        from fromView: UIView,
        to toView: UIView,
        animated: Bool,
        completion: UpdateUICompletion? = nil
    ) {
        UIView.transition(
            from: fromView,
            to: toView,
            duration: animated ? 0.3 : 0,
            options: [.transitionCrossDissolve, .showHideTransitionViews],
            completion: completion
        )
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addWebView() {
        /// <note>
        /// The transition state should be maintained manually at the beginning because both views
        /// are being added so it won't be detected that which view is actually visible. It seems
        /// like `isHidden` property is the only way to prevent unnecessary transition.
        webView.isHidden = true

        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.safeEqualToTop(of: self)
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        if let userAgent {
            webView.customUserAgent = userAgent
        }

        webView.navigationDelegate = self
        webView.uiDelegate = self

        addRefreshControlIfNeeded()
    }

    private func addRefreshControlIfNeeded() {
        if !allowsPullToRefresh { return }

        let refreshControl = UIRefreshControl()
        webView.scrollView.refreshControl = refreshControl

        refreshControl.addTarget(
            self,
            action: #selector(didPullToRefresh),
            for: .valueChanged
        )
    }
    
    @objc
    func didPullToRefresh() {
        webView.reload()
    }

    private func addNoContent() {
        view.addSubview(noContentView)
        noContentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        noContentView.startObserving(event: .retry) {
            [weak self] in
            guard let self else { return }
            load(url: self.lastURL)
        }
    }

    func updateUIForLoading() {
        let state = InAppBrowserNoContentView.State.loading(theme.loading)
        updateUI(for: state)
    }

    func updateUIForURL() {
        let clearNoContent = {
            [weak self] in
            guard let self else { return }

            self.noContentView.setState(
                nil,
                animated: false
            )
        }

        if !webView.isHidden {
            clearNoContent()
            return
        }

        updateUI(
            from: noContentView,
            to: webView,
            animated: isViewAppeared
        ) { isCompleted in
            if !isCompleted { return }
            clearNoContent()
        }
    }

    func updateUIForError(_ error: Error) {
        defer {
            endRefreshingIfNeeded()
        }

        if !isPresentable(error) {
            updateUIForURL()
            return
        }

        let viewModel = InAppBrowserErrorViewModel(error: error)
        let state = InAppBrowserNoContentView.State.error(theme.error, viewModel)
        updateUI(for: state)
    }
    
    private func endRefreshingIfNeeded() {
        if !allowsPullToRefresh { return }

        webView.scrollView.refreshControl?.endRefreshing()
    }
    
    // MARK: - WKUIDelegate
    
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }
    
    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let controller = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(
            title: String(localized: "title-ok"),
            style: .default
        ) { _ in
            completionHandler(true)
        }
        controller.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(
            title: String(localized: "title-cancel"),
            style: .cancel
        ) { _ in
            completionHandler(false)
        }
        controller.addAction(cancelAction)

        present(
            controller,
            animated: true
        )
    }

    // MARK: - WKNavigationDelegate
    
    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        updateUIForLoading()
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        updateUIForError(error)
    }

    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        updateUIForURL()
        endRefreshingIfNeeded()
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        updateUIForError(error)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel, preferences)
            return
        }

        if url.isMailURL {
            decisionHandler(navigateToMail(url), preferences)
            return
        }
        if let socialMediaURL = socialMediaDeeplinkParser.route(url: url) {
            decisionHandler(navigateToSocialMedia(socialMediaURL), preferences)
            return
        }
        if let walletConnectSessionURL = DeeplinkQR(url: url).walletConnectUrl() {
            decisionHandler(navigateToWalletConnectSession(walletConnectSessionURL), preferences)
            return
        }
        
        decisionHandler(url.isWebURL ? .allow : .cancel, preferences)
    }
    
    private func navigateToMail(_ url: URL) -> WKNavigationActionPolicy {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }

        return .cancel
    }

    private func navigateToSocialMedia(_ url: URL) -> WKNavigationActionPolicy {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }

        return .cancel
    }

    private func navigateToWalletConnectSession(_ url: URL) -> WKNavigationActionPolicy {
        let src: DeeplinkSource = .walletConnectSessionRequestForDiscover(url)
        launchController.receive(deeplinkWithSource: src)
        return .cancel
    }

    // MARK: - WKScriptMessageHandler
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard configuration.featureFlagService.isEnabled(.webviewV2Enabled) else {
            parseWebViewMessageV1(message)
            return
        }
        
        guard let scriptMessage = WebViewV2Message(rawValue: message.name) else { return }
        switch scriptMessage {
        case .pushWebView:
            break
        case .openSystemBrowser:
            break
        case .canOpenUri:
            break
        case .openNativeURI:
            break
        case .notifyUser:
            break
        case .getAddresses:
            break
        case .getSettings:
            break
        case .getPublicSettings:
            break
        case .onBackPressed:
            break
        case .logAnalyticsEvent:
            break
        case .closeWebView:
            break
        }
        
    }
    
    private func parseWebViewMessageV1(_ message: WKScriptMessage) {
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
    
    // MARK: - Helpers
    
    private func isPresentable(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else { return true }
        return urlError.code != .cancelled
    }
    
    private func decode<T: Decodable>(_ message: WKScriptMessage) -> T? {
        guard
            let jsonString = message.body as? String,
            let jsonData = jsonString.data(using: .utf8)
        else { return nil }

        return try? JSONDecoder().decode(T.self, from: jsonData)
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
    
    private func handleDiscoverAssetDetail(_ inAppMessage: DiscoverAssetDetailScriptMessage, _ message: WKScriptMessage) {
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
        guard let params: DiscoverAssetParameters = decode(message) else { return }
        navigateToAssetDetail(params)
    }
    
    private func navigateToAssetDetail(_ params: DiscoverAssetParameters) {
        open(
            .discoverAssetDetail(params),
            by: .push
        )
    }
    
    private func handleTokenAction(_ message: WKScriptMessage) {
        guard let params: DiscoverSwapParameters = decode(message) else { return }

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

        guard configuration.featureFlagService.isEnabled(.swapV2Enabled) else {
            swapAssetFlowCoordinator.updateDraft(draft)
            swapAssetFlowCoordinator.launch()
            return
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
        guard let params: DiscoverGenericParameters = decode(message) else { return }
        openInBrowser(params.url)
    }
    
    private func handleRequestAuthorizedAddresses(_ message: WKScriptMessage, isAuthorizedAccountsOnly: Bool) {
        let handler = BrowserAuthorizedAddressEventHandler(sharedDataController: sharedDataController)
        handler.returnAuthorizedAccounts(message, in: webView, isAuthorizedAccountsOnly: isAuthorizedAccountsOnly)
    }
    
    private func handleDappDetailAction(_ message: WKScriptMessage) {
        if !message.isAcceptable { return }
        guard let params: DiscoverDappParamaters = decode(message) else { return }
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
        guard let params: DiscoverGenericParameters = decode(message) else { return }
        navigateToDiscoverGeneric(params)
    }

    private func navigateToDiscoverGeneric(_ params: DiscoverGenericParameters) {
        open(
            .discoverGeneric(params),
            by: .push
        )
    }
    
    private func handlePaymentRequestAction(_ message: WKScriptMessage) {
        guard let params: BidaliPaymentParameters = decode(message),
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
        guard let params: BidaliOpenURLParameters = decode(message),
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
