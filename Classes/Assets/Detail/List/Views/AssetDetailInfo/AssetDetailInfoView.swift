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
    private lazy var assetNameLabel = UILabel()
    private lazy var assetIDLabel = UILabel()
    private lazy var assetIDInfoButton = UIButton()

    func customize(_ theme: AssetDetailInfoViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addYourBalanceTitleLabel(theme)
        addBalanceLabel(theme)
        addAssetNameLabel(theme)
        addAssetIDLabel(theme)
        addAssetIDInfoButton(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension AssetDetailInfoView {
    private func addYourBalanceTitleLabel(_ theme: AssetDetailInfoViewTheme) {
        yourBalanceTitleLabel.customizeAppearance(theme.yourBalanceTitleLabel)

        addSubview(yourBalanceTitleLabel)
        yourBalanceTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(theme.horizontalPadding)
        }
    }

    private func addBalanceLabel(_ theme: AssetDetailInfoViewTheme) {
        balanceLabel.customizeAppearance(theme.balanceLabel)

        addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(yourBalanceTitleLabel.snp.bottom).offset(theme.yourBalanceTitleLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        balanceLabel.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addAssetNameLabel(_ theme: AssetDetailInfoViewTheme) {
        assetNameLabel.customizeAppearance(theme.assetNameLabel)

        addSubview(assetNameLabel)
        assetNameLabel.snp.makeConstraints {
            $0.top.equalTo(balanceLabel.snp.bottom).offset(65)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        assetNameLabel.addSeparator(theme.separator, padding: -63)
    }

    private func addAssetIDLabel(_ theme: AssetDetailInfoViewTheme) {
        assetIDLabel.customizeAppearance(theme.assetIDLabel)

        addSubview(assetIDLabel)
        assetIDLabel.snp.makeConstraints {
            $0.top.equalTo(assetNameLabel.snp.bottom).offset(theme.assetIDLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.lessThanOrEqualToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(35)
        }
    }

    private func addAssetIDInfoButton(_ theme: AssetDetailInfoViewTheme) {
        assetIDInfoButton.customizeAppearance(theme.assetIDInfoButton)

        addSubview(assetIDInfoButton)
        assetIDInfoButton.snp.makeConstraints {
            $0.leading.equalTo(assetIDLabel.snp.trailing).offset(theme.assetIDInfoButtonLeadingPadding)
            $0.centerY.equalTo(assetIDLabel)
        }
    }
}

extension AssetDetailInfoView {
    func bindData() {
        preconditionFailure("Not implemented yet.")
        balanceLabel.text = "200.01"
        assetNameLabel.text = "Micro-Netflix 1/10,000 Share"
        assetIDLabel.text = "1239123"
    }
}
