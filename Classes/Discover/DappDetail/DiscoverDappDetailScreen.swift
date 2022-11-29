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

//   DiscoverDappDetailScreen.swift

import Foundation
import WebKit
import MacaroonUtils

final class DiscoverDappDetailScreen: InAppBrowserScreen {
    private lazy var navigationTitleView = DiscoverDappDetailNavigationView()

    private let dappParameters: DiscoverDappParamaters

    init(
        dappParameters: DiscoverDappParamaters,
        configuration: ViewControllerConfiguration
    ) {
        self.dappParameters = dappParameters
        super.init(configuration: configuration)
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = true
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        addNavigationTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = URL(string: dappParameters.url) else {
            return
        }

        let generatedUrl = DiscoverURLGenerator.generateUrl(
            discoverUrl: .other(url: url),
            theme: traitCollection.userInterfaceStyle,
            session: session
        )

        load(url: generatedUrl)
    }

    private func addNavigationTitle() {
        navigationTitleView.customize(DiscoverDappDetailNavigationViewTheme())

        navigationItem.titleView = navigationTitleView

        bindNavigationTitle()
    }

    private func bindNavigationTitle() {
        navigationTitleView.bindData(DiscoverDappDetailNavigationViewModel(dappParameters))
    }
}
