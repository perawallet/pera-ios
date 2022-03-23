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

//
//   AssetPreviewActionView.swift

import MacaroonUIKit
import UIKit

final class AssetPreviewActionView: View {
    weak var delegate: AssetPreviewActionViewDelegate?

    private lazy var imageView = AssetImageView()
    private lazy var assetNameVerticalStackView = UIStackView()
    private lazy var assetNameHorizontalStackView = UIStackView()
    private lazy var assetNameLabel = UILabel()
    private lazy var secondaryImageView = UIImageView()
    private lazy var assetShortNameLabel = UILabel()
    private lazy var actionButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
    }

    func customize(_ theme: AssetPreviewActionViewTheme) {
        addImage(theme)
        addAssetNameVerticalStackView(theme)
        addActionButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
}

extension AssetPreviewActionView {
    @objc
    func didTapActionButton() {
        delegate?.assetPreviewActionViewDidTapSendButton(self)
    }
}

extension AssetPreviewActionView {
    private func addImage(_ theme: AssetPreviewActionViewTheme) {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.verticalPadding)
        }
    }

    private func addAssetNameVerticalStackView(_ theme: AssetPreviewActionViewTheme) {
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

    private func addAssetNameHorizontalStackView(_ theme: AssetPreviewActionViewTheme) {
        assetNameVerticalStackView.addArrangedSubview(assetNameHorizontalStackView)
        assetNameHorizontalStackView.spacing = theme.secondaryImageLeadingPadding

        addAssetNameLabel(theme)
        addSecondaryImage(theme)
    }

    private func addAssetNameLabel(_ theme: AssetPreviewActionViewTheme) {
        assetNameLabel.customizeAppearance(theme.accountName)

        assetNameHorizontalStackView.addArrangedSubview(assetNameLabel)
    }

    private func addSecondaryImage(_ theme: AssetPreviewActionViewTheme) {
        assetNameHorizontalStackView.addArrangedSubview(secondaryImageView)
    }

    private func addAssetShortNameLabel(_ theme: AssetPreviewActionViewTheme) {
        assetShortNameLabel.customizeAppearance(theme.assetAndNFTs)

        assetNameVerticalStackView.addArrangedSubview(assetShortNameLabel)
    }

    private func addActionButton(_ theme: AssetPreviewActionViewTheme) {
        actionButton.customizeAppearance(theme.actionButton)

        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalTo(imageView.snp.centerY)
        }
    }
}

extension AssetPreviewActionView: ViewModelBindable {
    func bindData(_ viewModel: AssetPreviewViewModel?) {
        imageView.bindData(viewModel?.assetImageViewModel)
        assetNameLabel.editText = viewModel?.assetPrimaryTitle
        secondaryImageView.image = viewModel?.secondaryImage
        assetShortNameLabel.editText = viewModel?.assetSecondaryTitle
    }

    func prepareForReuse() {
        imageView.prepareForReuse()
        assetNameLabel.text = nil
        secondaryImageView.image = nil
        assetShortNameLabel.text = nil
    }
}

protocol AssetPreviewActionViewDelegate: AnyObject {
    func assetPreviewActionViewDidTapSendButton(_ assetPreviewActionView: AssetPreviewActionView)
}
