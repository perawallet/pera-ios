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
//   StatisticsDateOptionView.swift

import UIKit
import Macaroon

final class StatisticsDateOptionView: View {
    private lazy var titleLabel = UILabel()
    private lazy var selectedIconImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(StatisticsDateOptionViewTheme())
    }

    func customize(_ theme: StatisticsDateOptionViewTheme) {
        addTitleLabel(theme)
        addSelectedIconImageView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension StatisticsDateOptionView {
    private func addTitleLabel(_ theme: StatisticsDateOptionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.horizontalPadding)
            $0.centerY.bottom.equalToSuperview()
        }
    }

    private func addSelectedIconImageView(_ theme: StatisticsDateOptionViewTheme) {
        selectedIconImageView.customizeAppearance(theme.selectedImage)

        addSubview(selectedIconImageView)
        selectedIconImageView.snp.makeConstraints {
            $0.fitToSize(theme.selectedImageSize)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalToSuperview()
        }

        selectedIconImageView.isHidden = true
    }
}

extension StatisticsDateOptionView {
    func bindData(_ viewModel: StatisticsDateOptionViewModel) {
        titleLabel.text = viewModel.title
        selectedIconImageView.isHidden = !(viewModel.isSelected ?? false)
    }

    func select() {
        selectedIconImageView.isHidden = false
    }

    func deselect() {
        selectedIconImageView.isHidden = true
    }
}
