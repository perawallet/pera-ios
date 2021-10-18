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
//   StatisticsHeaderView.swift

import UIKit
import Macaroon

final class StatisticsHeaderView: View {
    weak var delegate: AlgoAnalyticsHeaderViewDelegate?

    private lazy var amountLabel = UILabel()
    private lazy var informationStackView = UIStackView()
    private lazy var valueChangeView = StatisticsValueChangeView()
    private lazy var dateStackView = UIStackView()
    private lazy var dateLabel = UILabel()
    private lazy var arrowDownImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(StatisticsHeaderViewTheme())
        linkInteractors()
    }

    func customize(_ theme: StatisticsHeaderViewTheme) {
        customizeBaseAppearance(backgroundColor: UIColor.clear)

        addAmountLabel(theme)
        addInformationStackView(theme)
    }

    func prepareLayout(_ layoutSheet: StatisticsHeaderViewTheme) {}

    func customizeAppearance(_ styleSheet: StatisticsHeaderViewTheme) {}

    func linkInteractors() {
        dateStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDate)))
    }
}

extension StatisticsHeaderView {
    @objc
    private func didTapDate() {
        delegate?.algoAnalyticsHeaderViewDidTapDate(self)
    }
}

extension StatisticsHeaderView {
    private func addAmountLabel(_ theme: StatisticsHeaderViewTheme) {
        amountLabel.customizeAppearance(theme.amountLabel)

        addSubview(amountLabel)
        amountLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
    }

    private func addInformationStackView(_ theme: StatisticsHeaderViewTheme) {
        informationStackView.distribution = .equalSpacing
        informationStackView.alignment = .center
        informationStackView.spacing = theme.horizontalSpacing

        addSubview(informationStackView)
        informationStackView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.top.equalTo(amountLabel.snp.bottom).offset(theme.stackViewTopPadding)
        }

        addValueChangeView(theme)
        addDateStackView(theme)
    }

    private func addValueChangeView(_ theme: StatisticsHeaderViewTheme) {
        valueChangeView.customize(theme.valueChangeViewTheme)

        valueChangeView.setContentHuggingPriority(.required, for: .horizontal)
        valueChangeView.setContentCompressionResistancePriority(.required, for: .horizontal)
        informationStackView.addArrangedSubview(valueChangeView)
    }

    private func addDateStackView(_ theme: StatisticsHeaderViewTheme) {
        informationStackView.addArrangedSubview(dateStackView)
        dateStackView.spacing = theme.dateStackViewSpacing

        addDateLabel(theme)
        addArrowDownImageView(theme)
    }

    private func addDateLabel(_ theme: StatisticsHeaderViewTheme) {
        dateLabel.customizeAppearance(theme.dateLabel)

        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateStackView.addArrangedSubview(dateLabel)
    }

    private func addArrowDownImageView(_ theme: StatisticsHeaderViewTheme) {
        arrowDownImageView.customizeAppearance(theme.arrowDown)
        arrowDownImageView.isHidden = true

        dateStackView.addArrangedSubview(arrowDownImageView)
    }
}

extension StatisticsHeaderView: ViewModelBindable {
    func bindData(_ viewModel: StatisticsHeaderViewModel?) {
        guard let viewModel = viewModel else { return }

        amountLabel.text = viewModel.amount
        dateLabel.text = viewModel.date
        valueChangeView.isHidden = !viewModel.isValueChangeDisplayed
        arrowDownImageView.isHidden = viewModel.isDateSelectionArrowHidden 

        if viewModel.isValueChangeDisplayed {
            valueChangeView.bindData(viewModel.valueChangeViewModel)
        }
    }
}

enum ValueChangeStatus {
    case increased
    case decreased
    case stable
}

protocol AlgoAnalyticsHeaderViewDelegate: AnyObject {
    func algoAnalyticsHeaderViewDidTapDate(_ view: StatisticsHeaderView)
}
