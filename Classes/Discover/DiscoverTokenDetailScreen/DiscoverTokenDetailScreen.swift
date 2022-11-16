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

//   DiscoverTokenDetailScreen.swift

import Foundation
import WebKit
import MacaroonUtils

final class DiscoverTokenDetailScreen: WebScreen {
    private let tokenDetail: DiscoverTokenDetail

    init(
        tokenDetail: DiscoverTokenDetail,
        configuration: ViewControllerConfiguration
    ) {
        self.tokenDetail = tokenDetail
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var queryItems: [URLQueryItem] = []
        queryItems.append(.init(name: "poolId", value: tokenDetail.poolId))
        queryItems.append(.init(name: "theme", value: interfaceTheme.rawValue))

        var components = URLComponents(string: "https://discover-mobile-staging.perawallet.app/token-detail/\(tokenDetail.tokenId)/")
        components?.queryItems = queryItems

        load(url: components?.url)
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = true
    }
}
