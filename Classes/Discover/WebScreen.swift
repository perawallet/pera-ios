// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WebScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import WebKit

class WebScreen: BaseViewController {
    private lazy var theme = WebScreenTheme()

    private(set) lazy var interfaceTheme: InterfaceTheme = isDarkMode ? .dark : .light {
        didSet { updateInterfaceTheme() }
    }

    private(set) lazy var contentController = WKUserContentController()
    
    private(set) lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.userContentController = contentController
        configuration.preferences = WKPreferences()
        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false

        let selectionString  = """
        var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}textarea,input{user-select:text;-webkit-user-select:text;}';
        var head = document.head || document.getElementsByTagName('head')[0];
        var style = document.createElement('style'); style.type = 'text/css';
        style.appendChild(document.createTextNode(css)); head.appendChild(style);
"""
        let selectionScript = WKUserScript(
            source: selectionString,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        webView.configuration.userContentController.addUserScript(selectionScript)
        return webView
    }()

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        
        if userInterfaceStyle == .dark {
            interfaceTheme = .dark
        } else {
            interfaceTheme = .light
        }
    }
}

extension WebScreen {
    func load(url: URL?) {
        guard let url = url else {
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension WebScreen {
    private func updateInterfaceTheme() {
        let theme = interfaceTheme.rawValue
        let script = "updateTheme('\(theme)')"
        webView.evaluateJavaScript(script)
    }
}

extension WebScreen {
    private func addUI() {
        addBackground()
        addWebView()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addWebView() {
        webView.isOpaque = false
        webView.backgroundColor = .clear

        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges == 0
        }
    }
}

extension WebScreen {
    enum InterfaceTheme: String {
        case dark = "dark-theme"
        case light = "light-theme"
    }
}
