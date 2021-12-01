// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AccountPortfolioView.swift

import MacaroonUIKit
import UIKit

final class AccountPortfolioView: View {
    private lazy var titleLabel = Label()
    private lazy var portfolioValueLabel = Label()
    private lazy var algoHoldingsTitleLabel = Label()
    private lazy var algoHoldingsValueButton = Button()
    private lazy var assetHoldingsTitleLabel = Label()
    private lazy var assetHoldingsValueLabel = Label()

    func customize(_ theme: AccountPortfolioViewTheme) {
        addTitleLabel(theme)
        addPortfolioValueLabel(theme)
        addAlgoHoldingsTitleLabel(theme)
        addAlgoHoldingsValueButton(theme)
        addAssetHoldingsTitleLabel(theme)
        addAssetHoldingsValueLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension AccountPortfolioView {
    private func addTitleLabel(_ theme: AccountPortfolioViewTheme) {

    }

    private func addPortfolioValueLabel(_ theme: AccountPortfolioViewTheme) {

    }

    private func addAlgoHoldingsTitleLabel(_ theme: AccountPortfolioViewTheme) {

    }

    private func addAlgoHoldingsValueButton(_ theme: AccountPortfolioViewTheme) {

    }

    private func addAssetHoldingsTitleLabel(_ theme: AccountPortfolioViewTheme) {

    }

    private func addAssetHoldingsValueLabel(_ theme: AccountPortfolioViewTheme) {

    }
}

extension AccountPortfolioView: ViewModelBindable {
    func bindData(_ viewModel: AccountPortfolioViewModel?) {

    }
}

final class AccountPortfolioCell: BaseCollectionViewCell<AccountPortfolioView> {

    override func configureAppearance() {
        super.configureAppearance()
        contextView.customize(AccountPortfolioViewTheme())
    }
}
