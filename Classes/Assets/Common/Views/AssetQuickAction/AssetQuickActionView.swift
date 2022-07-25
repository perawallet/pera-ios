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

//   AssetQuickActionView.swift

import UIKit
import MacaroonUIKit

final class AssetQuickActionView: View {
    private lazy var button = MacaroonUIKit.Button()
    private lazy var titleLabel = Label()
    private lazy var accountTypeImageView = ImageView()
    private lazy var accountNameLabel = Label()

    func customize(_ theme: AssetQuickActionViewTheme) {
        addButton(theme)
        addTitle(theme)
        addAccountTypeImage(theme)
        addAccountName(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AssetQuickActionView {
    private func addButton(_ theme: AssetQuickActionViewTheme) {
        button.contentEdgeInsets = UIEdgeInsets(theme.buttonContentInsets)
        button.draw(corner: theme.buttonCorner)

        addSubview(button)
        button.snp.makeConstraints {
            $0.top == theme.topPadding
            $0.trailing == theme.horizontalPadding
            $0.bottom == theme.bottomPadding
        }
    }

    private func addTitle(_ theme: AssetQuickActionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top == theme.topPadding
            $0.leading == theme.horizontalPadding
            $0.trailing >= button.snp.leading + theme.spacingBetweenTitleAndButton
        }
    }

    private func addAccountTypeImage(_ theme: AssetQuickActionViewTheme) {
        addSubview(accountTypeImageView)
        accountTypeImageView.snp.makeConstraints {
            $0.fitToSize(theme.accountTypeImageSize)
            $0.leading == theme.horizontalPadding
            $0.top == titleLabel.snp.bottom + theme.accountTypeImageTopPadding
            $0.bottom == theme.bottomPadding
        }
    }

    private func addAccountName(_ theme: AssetQuickActionViewTheme) {
        accountNameLabel.customizeAppearance(theme.accountName)

        addSubview(accountNameLabel)
        accountNameLabel.snp.makeConstraints {
            $0.centerY == accountTypeImageView
            $0.leading == accountTypeImageView.snp.trailing + theme.spacingBetweenAccountTypeAndName
            $0.trailing >= button.snp.trailing + theme.spacingBetweenTitleAndButton
        }
    }
}
