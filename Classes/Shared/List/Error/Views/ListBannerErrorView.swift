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
//   ListBannerErrorView.swift

import UIKit
import MacaroonUIKit

final class ListBannerErrorView: View {
    private lazy var iconView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var detailLabel = UILabel()
    private lazy var actionButton = UIButton()

    func customize(_ theme: ListBannerErrorViewTheme) {
        addIconView(theme)
        addActionButton(theme)
        addTitleLabel(theme)
        addDetailLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension ListBannerErrorView {
    private func addIconView(_ theme: ListBannerErrorViewTheme) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.size.equalTo(CGSize(theme.iconSize))
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalToSuperview()
        }
    }

    private func addActionButton(_ theme: ListBannerErrorViewTheme) {
        actionButton.customizeAppearance(theme.action)

        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalToSuperview()
        }
    }

    private func addTitleLabel(_ theme: ListBannerErrorViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(theme.titleHorizontalPadding)
            $0.top.equalToSuperview().inset(theme.verticalPadding)
            $0.trailing.equalTo(actionButton.snp.leading).offset(-theme.titleHorizontalPadding)
        }
    }

    private func addDetailLabel(_ theme: ListBannerErrorViewTheme) {
        detailLabel.customizeAppearance(theme.detail)

        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(theme.detailTopPadding)
            $0.bottom.equalToSuperview().inset(theme.verticalPadding + safeAreaBottom)
            $0.trailing.equalTo(actionButton.snp.leading).offset(-theme.titleHorizontalPadding)
        }
    }
}

extension ListBannerErrorView: ViewModelBindable {
    func bindData(_ viewModel: ListBannerErrorViewModel?) {

    }
}
