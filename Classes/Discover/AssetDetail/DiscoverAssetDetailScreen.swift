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

//   DiscoverAssetDetailScreen.swift

import Foundation
import WebKit
import MacaroonUtils

final class DiscoverAssetDetailScreen: InAppBrowserScreen, WKScriptMessageHandler {
    private let assetParameters: DiscoverAssetParameters

    private var events: [Event] = [.detailAction]

    init(
        assetParameters: DiscoverAssetParameters,
        configuration: ViewControllerConfiguration
    ) {
        self.assetParameters = assetParameters
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let generatedUrl = DiscoverURLGenerator.generateUrl(
            discoverUrl: .assetDetail(parameters: assetParameters),
            theme: traitCollection.userInterfaceStyle,
            session: session
        )
        load(url: generatedUrl)
        listenEvents()
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = true
    }


}

extension DiscoverAssetDetailScreen {
    enum Event: String {
        case detailAction = "handleTokenDetailActionButtonClick"
    }

    private func listenEvents() {
        events.forEach { event in
            contentController.add(self, name: event.rawValue)
        }
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        print(message.body)
        guard let jsonString = message.body as? String,
              let jsonData = jsonString.data(using: .utf8) else {
            return
        }

        let jsonDecoder = JSONDecoder()

        if let swapParameters = try? jsonDecoder.decode(DiscoverSwapParameters.self, from: jsonData) {
            print(swapParameters)
            return
        }
    }
}
