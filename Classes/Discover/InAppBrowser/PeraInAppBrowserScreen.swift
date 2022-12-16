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

//   PeraInAppBrowserScreen.swift

import Foundation
import UIKit

/// <note>:
/// PeraInAppBrowserScreen should be used for websites that created by Pera
/// It handles theme changes, some common logics on that websites.
class PeraInAppBrowserScreen: InAppBrowserScreen {
    var discoverURL: DiscoverURL {
        fatalError("It should be set in necessary screen")
    }

    deinit {
        stopObservingNotifications()
    }

    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)

        startObservingNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateInterfaceTheme(self.traitCollection.userInterfaceStyle)
    }

    override func viewDidLoad() {
        updateUserAgent()
        super.viewDidLoad()
        loadGeneratedURL()
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        updateInterfaceTheme(userInterfaceStyle)
    }

    override func didPullToRefresh() {
        do {
            let generatedUrl = try generateURL()

            guard generatedUrl == webView.url else {
                load(url: generatedUrl)
                return
            }

            super.didPullToRefresh()

        } catch {
            super.didPullToRefresh()
        }
    }
}

extension PeraInAppBrowserScreen {
    private func generateURL() throws -> URL {
        do {
            return try DiscoverURLGenerator.generateUrl(
                discoverUrl: discoverURL,
                theme: traitCollection.userInterfaceStyle,
                session: session
            )
        } catch {
            throw error
        }
    }

    private func loadGeneratedURL() {
        do {
            let generatedUrl = try generateURL()
            load(url: generatedUrl)
        } catch {
            print(error)
        }
    }
}

extension PeraInAppBrowserScreen {
    private func updateUserAgent() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let versionString = "pera_ios_\(version)"
            if let userAgent = webView.value(forKey: "userAgent") as? String {
                webView.customUserAgent = "\(userAgent) \(versionString)"
            } else {
                webView.customUserAgent = versionString
            }
        }
    }

    private func updateInterfaceTheme(_ style: UIUserInterfaceStyle) {
        let theme = style.peraThemeValue
        let script = "updateTheme('\(theme)')"
        webView.evaluateJavaScript(script)
    }

    private func updateCurrency() {
        guard let newCurrency = session?.preferredCurrencyID.localValue else {
            return
        }
        let script = "updateCurrency('\(newCurrency)')"
        webView.evaluateJavaScript(script)
    }
}

extension PeraInAppBrowserScreen {
    private func startObservingNotifications() {
        startObservingAppLifeCycleNotifications()
        startObservingCurrencyNotification()
    }

    private func startObservingAppLifeCycleNotifications() {
        observeWhenApplicationDidBecomeActive {
            [weak self] _ in
            guard let self else { return }
            self.updateInterfaceTheme(self.traitCollection.userInterfaceStyle)
        }
    }

    private func startObservingCurrencyNotification() {
        observe(notification: CurrencySelectionViewController.didChangePreferredCurrency) {
            [weak self] _ in
            guard let self else { return }
            self.updateCurrency()
        }
    }
}


extension UIUserInterfaceStyle {
    var peraThemeValue: String {
        switch self {
        case .dark:
            return "dark-theme"
        default:
            return "light-theme"
        }
    }
}
