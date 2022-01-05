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
//   AssetDetailInfoView.swift

import MacaroonUIKit
import UIKit

final class AssetDetailInfoView: View {
    private lazy var yourBalanceTitleLabel = UILabel()
    private lazy var balanceLabel = UILabel()
    private lazy var horizontalStackView = UIStackView()
    private lazy var assetNameLabel = UILabel()
    private lazy var assetIDLabel = UILabel()
    private lazy var verifiedImage = UIImageView()

    func customize(_ theme: AssetDetailInfoViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addYourBalanceTitleLabel(theme)
        addBalanceLabel(theme)
        addAssetNameLabel(theme)
        addAssetIDLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
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

        balanceLabel.addSeparator(theme.separator, padding: theme.topSeparatorTopPadding)
    }

    private func addAssetNameLabel(_ theme: AssetDetailInfoViewTheme) {
        addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints {
            $0.top.equalTo(balanceLabel.snp.bottom).offset(theme.assetNameLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        assetNameLabel.customizeAppearance(theme.assetNameLabel)
        horizontalStackView.addArrangedSubview(assetNameLabel)
        verifiedImage.customizeAppearance(theme.verifiedImage)
        horizontalStackView.addArrangedSubview(verifiedImage)
        
        horizontalStackView.addSeparator(theme.separator, padding: theme.bottomSeparatorTopPadding)
    }

    private func addAssetIDLabel(_ theme: AssetDetailInfoViewTheme) {
        assetIDLabel.customizeAppearance(theme.assetIDLabel)

        addSubview(assetIDLabel)
        assetIDLabel.snp.makeConstraints {
            $0.top.equalTo(assetNameLabel.snp.bottom).offset(theme.assetIDLabelTopPadding)
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
        assetNameLabel.text = viewModel?.name
        assetIDLabel.text = viewModel?.ID
    }
}
