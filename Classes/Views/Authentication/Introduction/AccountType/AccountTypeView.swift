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
//  AccountTypeView.swift

import UIKit

final class AccountTypeView: Control {
    private lazy var theme = AccountTypeViewTheme()
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var detailLabel = UILabel()

    func customize(_ theme: AccountTypeViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addDetailLabel(theme)
    }
}

extension AccountTypeView {
    private func addImageView(_ theme: AccountTypeViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.iconSize)
            $0.centerY.equalToSuperview()
        }
    }

    private func addTitleLabel(_ theme: AccountTypeViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.trailing.equalToSuperview().inset(theme.titleTrailingInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(theme.titleTrailingInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.minimumInset)
            $0.bottom.equalToSuperview().offset(-theme.verticalInset)
        }

        detailLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}

extension AccountTypeView {
    func bind(_ viewModel: AccountTypeViewModel) {
        typeImageView.image = viewModel.typeImage
        titleLabel.text = viewModel.title
        detailLabel.text = viewModel.detail
    }
}

extension AccountTypeView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let iconSize = CGSize(width: 48.0, height: 48.0)
        let titleLeadingInset: CGFloat = 88.0
        let titleTrailingInset: CGFloat = 60.0
        let arrowIconSize = CGSize(width: 24.0, height: 24.0)
        let separatorHeight: CGFloat = 1.0
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 24.0
        let minimumInset: CGFloat = 4.0
    }
}
