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
//   AssetDetailInfoView.swift

import MacaroonUIKit
import UIKit

final class AssetDetailInfoView: View {
    weak var delegate: AssetDetailInfoViewDelegate?

    private lazy var yourBalanceTitleLabel = UILabel()
    private lazy var balanceLabel = UILabel()
    private lazy var secondaryValueLabel = UILabel()
    private lazy var assetNameView = UIView()
    private lazy var assetNameLabel = UILabel()
    private lazy var assetIDButton = Button(.imageAtRight(spacing: 8))
    private lazy var verifiedImage = UIImageView()

    func setListeners() {
        assetIDButton.addTarget(self, action: #selector(notifyDelegateToCopyAssetID), for: .touchUpInside)
    }

    func customize(_ theme: AssetDetailInfoViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addYourBalanceTitleLabel(theme)
        addBalanceLabel(theme)
        addSecondaryValueLabel(theme)
        addAssetNameLabel(theme)
        addAssetIDButton(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension AssetDetailInfoView {
    @objc
    private func notifyDelegateToCopyAssetID() {
        delegate?.assetDetailInfoViewDidTapAssetID(self, assetID: assetIDButton.title(for: .normal))
    }
}

extension AssetDetailInfoView {
    private func addYourBalanceTitleLabel(_ theme: AssetDetailInfoViewTheme) {
        yourBalanceTitleLabel.customizeAppearance(theme.yourBalanceTitleLabel)

        addSubview(yourBalanceTitleLabel)
        yourBalanceTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topPadding)
            $0.leading.equalToSuperview().offset(theme.horizontalPadding)
        }
    }

    private func addBalanceLabel(_ theme: AssetDetailInfoViewTheme) {
        balanceLabel.customizeAppearance(theme.balanceLabel)

        addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(yourBalanceTitleLabel.snp.bottom).offset(theme.balanceLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addSecondaryValueLabel(_ theme: AssetDetailInfoViewTheme) {
        secondaryValueLabel.customizeAppearance(theme.secondaryValueLabel)

        addSubview(secondaryValueLabel)
        secondaryValueLabel.snp.makeConstraints {
            $0.top.equalTo(balanceLabel.snp.bottom).offset(theme.secondaryValueLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        balanceLabel.addSeparator(theme.separator, padding: theme.topSeparatorTopPadding)
    }

    private func addAssetNameLabel(_ theme: AssetDetailInfoViewTheme) {
        addSubview(assetNameView)
        assetNameView.snp.makeConstraints {
            $0.top.equalTo(balanceLabel.snp.bottom).offset(theme.assetNameLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        assetNameLabel.customizeAppearance(theme.assetNameLabel)
        assetNameView.addSubview(assetNameLabel)
        assetNameLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        verifiedImage.customizeAppearance(theme.verifiedImage)
        assetNameView.addSubview(verifiedImage)
        verifiedImage.snp.makeConstraints {
            $0.leading.equalTo(assetNameLabel.snp.trailing).offset(theme.verifiedImageHorizontalSpacing)
        }
        
        assetNameView.addSeparator(theme.separator, padding: theme.bottomSeparatorTopPadding)
    }

    private func addAssetIDButton(_ theme: AssetDetailInfoViewTheme) {
        assetIDButton.customizeAppearance(theme.assetIDButton)

        addSubview(assetIDButton)
        assetIDButton.snp.makeConstraints {
            $0.top.equalTo(assetNameView.snp.bottom).offset(theme.assetIDLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.lessThanOrEqualToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(theme.bottomPadding)
        }
    }
}

extension AssetDetailInfoView: ViewModelBindable {
    func bindData(_ viewModel: AssetDetailInfoViewModel?) {
        verifiedImage.isHidden = !(viewModel?.isVerified ?? false)
        balanceLabel.text = viewModel?.amount
        secondaryValueLabel.text = viewModel?.secondaryValue
        assetNameLabel.text = viewModel?.name
        assetIDButton.setTitle(viewModel?.ID, for: .normal)
    }
}

protocol AssetDetailInfoViewDelegate: AnyObject {
    func assetDetailInfoViewDidTapAssetID(_ assetDetailInfoView: AssetDetailInfoView, assetID: String?)
}
