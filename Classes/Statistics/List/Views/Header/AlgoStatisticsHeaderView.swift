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
//   AlgoStatisticsHeaderView.swift

import UIKit
import MacaroonUIKit

final class AlgoStatisticsHeaderView: View {
    private lazy var amountLabel = UILabel()
    private lazy var informationStackView = UIStackView()
    private lazy var valueChangeView = AlgoStatisticsValueChangeView()
    private lazy var dateLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(AlgoStatisticsHeaderViewTheme())
    }

    func customize(_ theme: AlgoStatisticsHeaderViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addAmountLabel(theme)
        addValueChangeView(theme)
        addDateLabel(theme)
    }

    func prepareLayout(_ layoutSheet: AlgoStatisticsHeaderViewTheme) {}

    func customizeAppearance(_ styleSheet: AlgoStatisticsHeaderViewTheme) {}
}

extension AlgoStatisticsHeaderView {
    private func addAmountLabel(_ theme: AlgoStatisticsHeaderViewTheme) {
        amountLabel.customizeAppearance(theme.amountLabel)

        addSubview(amountLabel)
        amountLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
    }

    private func addValueChangeView(_ theme: AlgoStatisticsHeaderViewTheme) {
        valueChangeView.customize(theme.valueChangeViewTheme)

        addSubview(valueChangeView)
        valueChangeView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.top.equalTo(amountLabel.snp.bottom).offset(theme.topPadding)
        }
    }

    private func addDateLabel(_ theme: AlgoStatisticsHeaderViewTheme) {
        dateLabel.customizeAppearance(theme.dateLabel)

        addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.top.equalTo(amountLabel.snp.bottom).offset(theme.topPadding)
        }
    }
}

extension AlgoStatisticsHeaderView: ViewModelBindable {
    func bindData(_ viewModel: AlgoStatisticsHeaderViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        amountLabel.text = viewModel.amount
        valueChangeView.isHidden = !viewModel.isValueChangeDisplayed
        dateLabel.isHidden = viewModel.isDateHidden

        if viewModel.isValueChangeDisplayed {
            valueChangeView.bindData(viewModel.valueChangeViewModel)
        } else {
            dateLabel.text = viewModel.date
        }
    }
}

enum ValueChangeStatus {
    case increased
    case decreased
    case stable
}
