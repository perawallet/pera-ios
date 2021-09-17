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
//   AssetPreviewView.swift

import Macaroon

final class AssetPreviewView: View {
    private lazy var imageView = AssetImageView()
    private lazy var assetNameVerticalStackView = UIStackView()
    private lazy var assetNameHorizontalStackView = UIStackView()
    private lazy var assetNameLabel = UILabel()
    private lazy var secondaryImageView = UIImageView()
    private lazy var assetShortNameLabel = UILabel()
    private lazy var valueVerticalStackView = UIStackView()
    private lazy var assetValueLabel = UILabel()
    private lazy var secondaryAssetValueLabel = UILabel()

    func customize(_ theme: AssetPreviewViewTheme) {
        addImage(theme)
        addAssetNameVerticalStackView(theme)
        addValueVerticalStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension AssetPreviewView {
    private func addImage(_ theme: AssetPreviewViewTheme) {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
        }
    }

    private func addAssetNameVerticalStackView(_ theme: AssetPreviewViewTheme) {
        addSubview(assetNameVerticalStackView)
        assetNameVerticalStackView.axis = .vertical

        assetNameVerticalStackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(imageView.snp.centerY)
        }

        addAssetNameHorizontalStackView(theme)
        addAssetShortNameLabel(theme)
    }

    private func addAssetNameHorizontalStackView(_ theme: AssetPreviewViewTheme) {
        assetNameVerticalStackView.addArrangedSubview(assetNameHorizontalStackView)
        assetNameHorizontalStackView.spacing = theme.secondaryImageLeadingPadding

        addAssetNameLabel(theme)
        addSecondaryImage(theme)
    }

    private func addAssetNameLabel(_ theme: AssetPreviewViewTheme) {
        assetNameLabel.customizeAppearance(theme.accountName)

        assetNameHorizontalStackView.addArrangedSubview(assetNameLabel)
    }

    private func addSecondaryImage(_ theme: AssetPreviewViewTheme) {
        assetNameHorizontalStackView.addArrangedSubview(secondaryImageView)
    }

    private func addAssetShortNameLabel(_ theme: AssetPreviewViewTheme) {
        assetShortNameLabel.customizeAppearance(theme.assetAndNFTs)

        assetNameVerticalStackView.addArrangedSubview(assetShortNameLabel)
    }

    private func addValueVerticalStackView(_ theme: AssetPreviewViewTheme) {
        addSubview(valueVerticalStackView)
        valueVerticalStackView.axis = .vertical
        valueVerticalStackView.alignment = .trailing

        valueVerticalStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(assetNameVerticalStackView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(assetNameVerticalStackView.snp.centerY)
        }

        addAssetValueLabel(theme)
        addSecondaryAssetValueLabel(theme)
    }

    private func addAssetValueLabel(_ theme: AssetPreviewViewTheme) {
        assetValueLabel.customizeAppearance(theme.assetValue)

        valueVerticalStackView.addArrangedSubview(assetValueLabel)
    }

    private func addSecondaryAssetValueLabel(_ theme: AssetPreviewViewTheme) {
        secondaryAssetValueLabel.customizeAppearance(theme.secondaryAssetValue)

        valueVerticalStackView.addArrangedSubview(secondaryAssetValueLabel)
    }
}

extension AssetPreviewView: ViewModelBindable {
    func bindData(_ viewModel: AssetPreviewViewModel?) {
        imageView.bindData(viewModel)
        assetNameLabel.text = viewModel?.assetName
        secondaryImageView.image = viewModel?.secondaryImage
        assetShortNameLabel.text = viewModel?.assetShortName
        assetValueLabel.text = viewModel?.assetValue
        secondaryAssetValueLabel.text = viewModel?.secondaryAssetValue
    }
}
