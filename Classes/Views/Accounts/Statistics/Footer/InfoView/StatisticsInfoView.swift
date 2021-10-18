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
//   StatisticsInfoView.swift

import Macaroon
import UIKit

final class StatisticsInfoView: View {
    private lazy var titleLabel = UILabel()
    private lazy var valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(StatisticsInfoViewTheme())
    }

    func customize(_ theme: StatisticsInfoViewTheme) {
        addTitleLabel(theme)
        addValueLabel(theme)
    }

    func prepareLayout(_ layoutSheet: StatisticsInfoViewTheme) {}

    func customizeAppearance(_ styleSheet: StatisticsInfoViewTheme) {}
}

extension StatisticsInfoView {
    func addTitleLabel(_ theme: StatisticsInfoViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
    }

    func addValueLabel(_ theme: StatisticsInfoViewTheme) {
        valueLabel.customizeAppearance(theme.value)

        addSubview(valueLabel)
        valueLabel.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom + theme.verticalPadding
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension StatisticsInfoView: ViewModelBindable {
    func bindData(_ viewModel: StatisticsInfoViewModel?) {
        valueLabel.text = viewModel?.value
        titleLabel.text = viewModel?.title
    }
}
