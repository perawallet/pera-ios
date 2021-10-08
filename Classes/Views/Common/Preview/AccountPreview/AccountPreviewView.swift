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
//   AccountPreviewView.swift

import Macaroon

final class AccountPreviewView: View {
    private lazy var imageView = UIImageView()
    private lazy var accountNameAndAssetsNFTsVerticalStackView = UIStackView()
    private lazy var accountNameLabel = UILabel()
    private lazy var assetsAndNFTsLabel = UILabel()
    private lazy var valueVerticalStackView = UIStackView()
    private lazy var assetValueLabel = UILabel()
    private lazy var secondaryAssetValueLabel = UILabel()

    func customize(_ theme: AccountPreviewViewTheme) {
        addImage(theme)
        addAccountNameAndAssetsNFTsVerticalStackView(theme)
        addValueVerticalStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension AccountPreviewView {
    private func addImage(_ theme: AccountPreviewViewTheme) {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.verticalPadding)
        }
    }

    private func addAccountNameAndAssetsNFTsVerticalStackView(_ theme: AccountPreviewViewTheme) {
        addSubview(accountNameAndAssetsNFTsVerticalStackView)
        accountNameAndAssetsNFTsVerticalStackView.axis = .vertical

        accountNameAndAssetsNFTsVerticalStackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(imageView.snp.centerY)
        }

        addAccountNameLabel(theme)
        addAssetsAndNFTsLabel(theme)
    }

    private func addAccountNameLabel(_ theme: AccountPreviewViewTheme) {
        accountNameLabel.customizeAppearance(theme.accountName)

        accountNameAndAssetsNFTsVerticalStackView.addArrangedSubview(accountNameLabel)
    }

    private func addAssetsAndNFTsLabel(_ theme: AccountPreviewViewTheme) {
        assetsAndNFTsLabel.customizeAppearance(theme.assetAndNFTs)

        accountNameAndAssetsNFTsVerticalStackView.addArrangedSubview(assetsAndNFTsLabel)
    }

    private func addValueVerticalStackView(_ theme: AccountPreviewViewTheme) {
        addSubview(valueVerticalStackView)
        valueVerticalStackView.axis = .vertical
        valueVerticalStackView.alignment = .trailing

        valueVerticalStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(accountNameAndAssetsNFTsVerticalStackView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(accountNameAndAssetsNFTsVerticalStackView.snp.centerY)
        }

        addAssetValueLabel(theme)
        addSecondaryAssetValueLabel(theme)
    }

    private func addAssetValueLabel(_ theme: AccountPreviewViewTheme) {
        assetValueLabel.customizeAppearance(theme.assetValue)

        valueVerticalStackView.addArrangedSubview(assetValueLabel)
    }

    private func addSecondaryAssetValueLabel(_ theme: AccountPreviewViewTheme) {
        secondaryAssetValueLabel.customizeAppearance(theme.secondaryAssetValue)

        valueVerticalStackView.addArrangedSubview(secondaryAssetValueLabel)
    }
}

extension AccountPreviewView {
    func bindData(_ viewModel: AccountPreviewViewModel?) {
        imageView.image = viewModel?.accountImageTypeImage
        accountNameLabel.text = viewModel?.accountName
        assetsAndNFTsLabel.text = viewModel?.assetsAndNFTs
        assetValueLabel.text = viewModel?.assetValue
        secondaryAssetValueLabel.text = viewModel?.secondaryAssetValue
    }
}
