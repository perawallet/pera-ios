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
//   AlgoStatisticsDateOptionView.swift

import UIKit
import MacaroonUIKit

final class AlgoStatisticsDateOptionView: View {
    private lazy var titleLabel = UILabel()
    private lazy var selectedIconImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(AlgoStatisticsDateOptionViewTheme())
    }

    func customize(_ theme: AlgoStatisticsDateOptionViewTheme) {
        addTitleLabel(theme)
        addSelectedIconImageView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension AlgoStatisticsDateOptionView {
    private func addTitleLabel(_ theme: AlgoStatisticsDateOptionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.horizontalPadding)
            $0.centerY.equalToSuperview()
        }
    }

    private func addSelectedIconImageView(_ theme: AlgoStatisticsDateOptionViewTheme) {
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

extension AlgoStatisticsDateOptionView {
    func bindData(_ viewModel: AlgoStatisticsDateOptionViewModel) {
        titleLabel.text = viewModel.title
        selectedIconImageView.isHidden = !(viewModel.isSelected.falseIfNil)
    }

    func deselect() {
        selectedIconImageView.isHidden = true
    }
}
