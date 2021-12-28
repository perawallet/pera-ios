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
    lazy var handlers = Handlers()

    private lazy var portfolioValueView = PortfolioValueView()
    private lazy var algoHoldingsTitleLabel = UILabel()
    private lazy var algoHoldingsValueButton = Button()
    private lazy var assetHoldingsTitleLabel = UILabel()
    private lazy var assetHoldingsValueLabel = UILabel()

    func customize(_ theme: AccountPortfolioViewTheme) {
        addPortfolioValueView(theme)
        addAssetHoldingsTitleLabel(theme)
        addAssetHoldingsValueLabel(theme)
        addAlgoHoldingsTitleLabel(theme)
        addAlgoHoldingsValueButton(theme)
    }

    func setListeners() {
        portfolioValueView.handlers.didTapTitle = { [weak self] in
            guard let self = self else {
                return
            }

            self.handlers.didTapPortfolioTitle?()
        }
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension AccountPortfolioView {
    private func addPortfolioValueView(_ theme: AccountPortfolioViewTheme) {
        addSubview(portfolioValueView)
        portfolioValueView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addAssetHoldingsTitleLabel(_ theme: AccountPortfolioViewTheme) {
        assetHoldingsTitleLabel.customizeAppearance(theme.assetHoldingsTitle)

        addSubview(assetHoldingsTitleLabel)
        assetHoldingsTitleLabel.snp.makeConstraints {
            $0.top.equalTo(portfolioValueView.snp.bottom).offset(theme.holdingsTopPadding)
            $0.trailing.equalToSuperview().inset(theme.valueTrailingInset)
        }
    }

    private func addAssetHoldingsValueLabel(_ theme: AccountPortfolioViewTheme) {
        assetHoldingsValueLabel.customizeAppearance(theme.assetHoldingsValue)

        addSubview(assetHoldingsValueLabel)
        assetHoldingsValueLabel.snp.makeConstraints {
            $0.top.equalTo(assetHoldingsTitleLabel.snp.bottom).offset(theme.valuesTopPadding)
            $0.leading.equalTo(assetHoldingsTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addAlgoHoldingsTitleLabel(_ theme: AccountPortfolioViewTheme) {
        algoHoldingsTitleLabel.customizeAppearance(theme.algoHoldingsTitle)

        addSubview(algoHoldingsTitleLabel)
        algoHoldingsTitleLabel.snp.makeConstraints {
            $0.top.equalTo(portfolioValueView.snp.bottom).offset(theme.holdingsTopPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addAlgoHoldingsValueButton(_ theme: AccountPortfolioViewTheme) {
        algoHoldingsValueButton.customizeAppearance(theme.algoHoldingsValue)

        addSubview(algoHoldingsValueButton)
        algoHoldingsValueButton.snp.makeConstraints {
            $0.top.equalTo(algoHoldingsTitleLabel.snp.bottom).offset(theme.valuesTopPadding)
            $0.leading.equalTo(algoHoldingsTitleLabel)
            $0.trailing.greaterThanOrEqualTo(assetHoldingsValueLabel.snp.leading).offset(theme.horizontalInset)
        }
    }
}

extension AccountPortfolioView: ViewModelBindable {
    func bindData(_ viewModel: AccountPortfolioViewModel?) {

    }
}

extension AccountPortfolioView {
    struct Handlers {
        var didTapPortfolioTitle: EmptyHandler?
    }
}

final class AccountPortfolioCell: BaseCollectionViewCell<AccountPortfolioView> {

    override func configureAppearance() {
        super.configureAppearance()
        contextView.customize(AccountPortfolioViewTheme())
    }
}
