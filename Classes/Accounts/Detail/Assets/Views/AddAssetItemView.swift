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
//   AddAssetItemView.swift

import UIKit
import MacaroonUIKit

final class AddAssetItemView: View {

    private lazy var iconView = UIImageView()
    private lazy var titleLabel = UILabel()

    func customize(_ theme: AddAssetItemViewTheme) {
        addIconView(theme)
        addTitleLabel(theme)
    }

    func prepareLayout(_ layoutSheet: AddAssetItemViewTheme) {}

    func customizeAppearance(_ styleSheet: AddAssetItemViewTheme) {}
}

extension AddAssetItemView {
    private func addIconView(_ theme: AddAssetItemViewTheme) {
        iconView.customizeAppearance(theme.icon)

        addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.equalToSuperview().inset(theme.iconLeadingInset)
            $0.size.equalTo(CGSize(theme.iconSize))
        }
    }

    private func addTitleLabel(_ theme: AddAssetItemViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.trailing.equalToSuperview().inset(theme.titleHorizontalPadding)
        }
    }
}

final class AddAssetItemFooterView: BaseSupplementaryView<AddAssetItemView> {

}
