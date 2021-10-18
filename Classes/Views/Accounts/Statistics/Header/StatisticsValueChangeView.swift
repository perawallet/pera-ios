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
//   StatisticsValueChangeView.swift

import UIKit
import Macaroon

final class StatisticsValueChangeView: View {
    private lazy var changeImageView = UIImageView()
    private lazy var changeLabel = UILabel()

    func customize(_ theme: StatisticsValueChangeViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addChangeImageView(theme)
        addChangeLabel(theme)
    }

    func prepareLayout(_ layoutSheet: StatisticsValueChangeViewTheme) {}

    func customizeAppearance(_ styleSheet: StatisticsValueChangeViewTheme) {}
}

extension StatisticsValueChangeView {
    private func addChangeImageView(_ theme: StatisticsValueChangeViewTheme) {
        addSubview(changeImageView)
        changeImageView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.fitToSize(theme.imageSize)
        }
    }

    private func addChangeLabel(_ theme: StatisticsValueChangeViewTheme) {
        changeLabel.customizeAppearance(theme.changeLabel)

        addSubview(changeLabel)
        changeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(changeImageView.snp.trailing).offset(theme.horizontalInset)
            $0.centerY.equalTo(changeImageView)
        }
    }
}

extension StatisticsValueChangeView: ViewModelBindable {
    func bindData(_ viewModel: StatisticsValueChangeViewModel?) {
        changeImageView.image = viewModel?.image
        changeLabel.textColor = viewModel?.valueColor
        changeLabel.text = viewModel?.value
    }
}
