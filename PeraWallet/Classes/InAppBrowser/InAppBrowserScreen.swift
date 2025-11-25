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
    
    private(set) lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: SwapDataLocalStore(),
        configuration: configuration,
        presentingScreen: self
    )
    
    private(set) lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )

    var extraUserScripts: [InAppBrowserScript] { [] }
    var handledMessages: [any InAppBrowserScriptMessage] { [] }
    var account: AccountHandle? = nil

    private(set) var userAgent: String? = nil
    private var sourceURL: URL?
    private var lastURL: URL? { webView.url ?? sourceURL }
    
    // MARK: - Initialisers
    enum WebViewV2Message: String, InAppBrowserScriptMessage {
        case pushWebView
        case openSystemBrowser
        case canOpenURI
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
        guard let url = url else { return }
        
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
    ) { }
    
    // MARK: - Helpers
    
    private func isPresentable(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else { return true }
        return urlError.code != .cancelled
    }
}
