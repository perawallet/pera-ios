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
//   AccountPortfolioErrorView.swift

import MacaroonUIKit
import UIKit

final class AccountPortfolioErrorView: View {
    private lazy var imageView = UIImageView()
    private lazy var messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        customize(AccountPortfolioErrorViewTheme())
    }

    private func customize(_ theme: AccountPortfolioErrorViewTheme) {
        addImageView(theme)
        addMessageLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension AccountPortfolioErrorView {
    private func addImageView(_ theme: AccountPortfolioErrorViewTheme) {
        imageView.customizeAppearance(theme.icon)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview()
            $0.size.equalTo(CGSize(theme.iconSize))
        }
    }

    private func addMessageLabel(_ theme: AccountPortfolioErrorViewTheme) {
        messageLabel.customizeAppearance(theme.message)

        addSubview(messageLabel)
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.messageLeadingInset)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(theme.separatorTopPadding + theme.separator.size)
        }

        messageLabel.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }
}

final class AccountPortfolioErrorSupplementaryView: BaseSupplementaryView<AccountPortfolioErrorView> {

}
