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
//   AssetPreviewSendView.swift

import Macaroon

final class AssetPreviewSendView: View {
    weak var delegate: AssetPreviewSendViewDelegate?

    private lazy var imageView = AssetImageView()
    private lazy var assetNameVerticalStackView = UIStackView()
    private lazy var assetNameHorizontalStackView = UIStackView()
    private lazy var assetNameLabel = UILabel()
    private lazy var secondaryImageView = UIImageView()
    private lazy var assetShortNameLabel = UILabel()
    private lazy var sendButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
    }

    func customize(_ theme: AssetPreviewSendViewTheme) {
        addImage(theme)
        addAssetNameVerticalStackView(theme)
        addSendButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
}

extension AssetPreviewSendView {
    @objc
    func didTapSendButton() {
        delegate?.assetPreviewSendViewDidTapSendButton(self)
    }
}

extension AssetPreviewSendView {
    private func addImage(_ theme: AssetPreviewSendViewTheme) {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.verticalPadding)
        }
    }

    private func addAssetNameVerticalStackView(_ theme: AssetPreviewSendViewTheme) {
        addSubview(assetNameVerticalStackView)
        assetNameVerticalStackView.axis = .vertical

        assetNameVerticalStackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.trailing.lessThanOrEqualToSuperview().inset(theme.assetNameVerticalStackViewTrailingPadding)
            $0.centerY.equalTo(imageView.snp.centerY)
        }

        addAssetNameHorizontalStackView(theme)
        addAssetShortNameLabel(theme)
    }

    private func addAssetNameHorizontalStackView(_ theme: AssetPreviewSendViewTheme) {
        assetNameVerticalStackView.addArrangedSubview(assetNameHorizontalStackView)
        assetNameHorizontalStackView.spacing = theme.secondaryImageLeadingPadding

        addAssetNameLabel(theme)
        addSecondaryImage(theme)
    }

    private func addAssetNameLabel(_ theme: AssetPreviewSendViewTheme) {
        assetNameLabel.customizeAppearance(theme.accountName)

        assetNameHorizontalStackView.addArrangedSubview(assetNameLabel)
    }

    private func addSecondaryImage(_ theme: AssetPreviewSendViewTheme) {
        assetNameHorizontalStackView.addArrangedSubview(secondaryImageView)
    }

    private func addAssetShortNameLabel(_ theme: AssetPreviewSendViewTheme) {
        assetShortNameLabel.customizeAppearance(theme.assetAndNFTs)

        assetNameVerticalStackView.addArrangedSubview(assetShortNameLabel)
    }

    private func addSendButton(_ theme: AssetPreviewSendViewTheme) {
        sendButton.customizeAppearance(theme.sendButton)

        addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalTo(imageView.snp.centerY)
        }
    }
}

extension AssetPreviewSendView: ViewModelBindable {
    func bindData(_ viewModel: AssetPreviewViewModel?) {
        imageView.bindData(viewModel)
        assetNameLabel.text = viewModel?.assetPrimaryTitle
        secondaryImageView.image = viewModel?.secondaryImage
        assetShortNameLabel.text = viewModel?.assetSecondaryTitle
    }
}

protocol AssetPreviewSendViewDelegate: AnyObject {
    func assetPreviewSendViewDidTapSendButton(_ assetPreviewSendView: AssetPreviewSendView)
}
