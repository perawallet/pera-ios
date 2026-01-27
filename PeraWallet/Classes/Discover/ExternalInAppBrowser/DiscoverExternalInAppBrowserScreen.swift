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

//   DiscoverExternalInAppBrowserScreen.swift

import Foundation
import WebKit
import MacaroonUtils
import MacaroonUIKit
import pera_wallet_core

class DiscoverExternalInAppBrowserScreen: InAppBrowserScreen {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }
    
    override var extraUserScripts: [InAppBrowserScript] { [.navigation, .peraConnect] }

    private(set) lazy var navigationTitleView = DiscoverExternalInAppBrowserNavigationView()

    private(set) lazy var toolbar = UIToolbar(frame: .zero)
    private lazy var homeButton = makeHomeButton()
    private lazy var previousButton = makePreviousButton()
    private lazy var nextButton = makeNextButton()

    private var isViewLayoutLoaded = false

    private let destination: DiscoverExternalDestination

    init(
        destination: DiscoverExternalDestination,
        configuration: ViewControllerConfiguration
    ) {
        self.destination = destination

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addNavigation()
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeWebView()
        addToolbarActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty || toolbar.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            isViewLayoutLoaded = true
            updateWebViewLayout()
        }
    }

    override func updateUIForLoading() {
        super.updateUIForLoading()
        updateToolbarActionsForLoading()
    }

    override func updateUIForURL() {
        super.updateUIForURL()

        updateTitle()
        updateToolbarActionsForURL()
    }

    override func updateUIForError(_ error: Error) {
        super.updateUIForError(error)

        updateTitle()
        updateToolbarActionsForError()
    }

    // MARK: - WKScriptMessageHandler
    
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        updateTitle()
        updateToolbarNavigationActions()
        
        if let inAppMessage = DiscoverExternalInAppBrowserScriptMessage(rawValue: message.name) {
            handleDiscoverExternal(inAppMessage, message)
        }
    }

    func updateToolbarActionsForLoading() {
        updateToolbarNavigationActions()
    }

    func updateToolbarActionsForURL() {
        updateToolbarNavigationActions()
    }

    func updateToolbarActionsForError() {
        updateToolbarNavigationActions()
    }

    private func initializeWebView() {
        let generatedURL = DiscoverURLGenerator.generateURL(
            destination: .external(destination),
            theme: traitCollection.userInterfaceStyle,
            session: session
        )
        load(url: generatedURL)
    }

    private func addNavigation() {
        hidesCloseBarButtonItem = true

        navigationTitleView.customize(DiscoverExternalInAppBrowserNavigationViewTheme())

        navigationItem.titleView = navigationTitleView

        addNavigationBarButtonItems()
    }

    private func addNavigationBarButtonItems() {
        self.leftBarButtonItems = [ makeCloseNavigationBarButtonItem() ]
        self.rightBarButtonItems = [ makeReloadBarButtonItem() ]
    }
    
    private func makeCloseNavigationBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .close(Colors.Text.main.uiColor)) {
            [unowned self] in
            self.eventHandler?(.goBack)
        }
    }

    private func makeReloadBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .reload) {
            [unowned self] in
            self.webView.reload()
        }
    }

    private func bindNavigationTitle(with item: WKBackForwardListItem) {
        navigationTitleView.bindData(DiscoverExternalInAppBrowserNavigationViewModel(item, title: webView.title))
    }
    
    private func bindNavigationTitleForCurrentURL() {
        navigationTitleView.bindData(DiscoverExternalInAppBrowserNavigationViewModel(title: webView.title, subtitle: webView.url?.presentationString))
    }
}

extension DiscoverExternalInAppBrowserScreen {
    private func makeHomeButton() -> UIBarButtonItem {
        let button = ALGBarButtonItem(kind: .discoverHome) {
            [unowned self] in
            defer {
                self.updateToolbarNavigationActions()
            }

            if let homePage = self.webView.backForwardList.backList.first {
                self.webView.go(to: homePage)
            }
        }
        return UIBarButtonItem(customView: LegacyBarButton(barButtonItem: button))
    }

    private func makePreviousButton() -> UIBarButtonItem {
        let button = ALGBarButtonItem(kind: .discoverPrevious) {
            [unowned self] in
            self.webView.goBack()
            self.updateToolbarNavigationActions()
        }
        return UIBarButtonItem(customView: LegacyBarButton(barButtonItem: button))
    }

    private func makeNextButton() -> UIBarButtonItem {
        let button = ALGBarButtonItem(kind: .discoverNext) {
            [unowned self] in
            self.webView.goForward()
            self.updateToolbarNavigationActions()
        }
        return UIBarButtonItem(customView: LegacyBarButton(barButtonItem: button))
    }

    private func addToolbarActions() {
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(view.safeAreaBottom)
        }

        var items = [UIBarButtonItem]()

        previousButton.isEnabled = false
        nextButton.isEnabled = false

        items.append( previousButton )
        items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append( nextButton )
        items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append( homeButton )

        toolbar.items = items
    }

    private func updateToolbarNavigationActions() {
        homeButton.isEnabled = webView.canGoBack
        previousButton.isEnabled = webView.canGoBack
        nextButton.isEnabled = webView.canGoForward
    }
    
    private func updateWebViewLayout() {
        webView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(view.safeAreaBottom + toolbar.bounds.height)
        }
    }
    
    private func updateTitle() {
        guard let item = webView.backForwardList.currentItem else {
            bindNavigationTitleForCurrentURL()
            return
        }

        bindNavigationTitle(with: item)
    }
}

extension DiscoverExternalInAppBrowserScreen {
    enum Event {
        case goBack
        case addToFavorites(DiscoverFavouriteDappDetails)
        case removeFromFavorites(DiscoverFavouriteDappDetails)
    }
}

enum DiscoverExternalInAppBrowserScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case peraconnect
}
