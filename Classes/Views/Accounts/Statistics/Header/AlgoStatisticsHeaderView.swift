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
import Macaroon

final class AlgoStatisticsHeaderView: View {
    weak var delegate: AlgoStatisticsHeaderViewDelegate?

    private lazy var amountLabel = UILabel()
    private lazy var informationStackView = UIStackView()
    private lazy var valueChangeView = AlgoStatisticsValueChangeView()
    private lazy var dateStackView = UIStackView()
    private lazy var dateLabel = UILabel()
    private lazy var arrowDownImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(AlgoStatisticsHeaderViewTheme())
        linkInteractors()
    }

    func customize(_ theme: AlgoStatisticsHeaderViewTheme) {
        customizeBaseAppearance(backgroundColor: UIColor.clear)

        addAmountLabel(theme)
        addInformationStackView(theme)
    }

    func prepareLayout(_ layoutSheet: AlgoStatisticsHeaderViewTheme) {}

    func customizeAppearance(_ styleSheet: AlgoStatisticsHeaderViewTheme) {}

    func linkInteractors() {
        dateStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDate)))
    }
}

extension AlgoStatisticsHeaderView {
    @objc
    private func didTapDate() {
        delegate?.algoStatisticsHeaderViewDidTapDate(self)
    }
}

extension AlgoStatisticsHeaderView {
    private func addAmountLabel(_ theme: AlgoStatisticsHeaderViewTheme) {
        amountLabel.customizeAppearance(theme.amountLabel)

        addSubview(amountLabel)
        amountLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
    }

    private func addInformationStackView(_ theme: AlgoStatisticsHeaderViewTheme) {
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

    private func addValueChangeView(_ theme: AlgoStatisticsHeaderViewTheme) {
        valueChangeView.customize(theme.valueChangeViewTheme)

        valueChangeView.setContentHuggingPriority(.required, for: .horizontal)
        valueChangeView.setContentCompressionResistancePriority(.required, for: .horizontal)
        informationStackView.addArrangedSubview(valueChangeView)
    }

    private func addDateStackView(_ theme: AlgoStatisticsHeaderViewTheme) {
        informationStackView.addArrangedSubview(dateStackView)
        dateStackView.spacing = theme.dateStackViewSpacing

        addDateLabel(theme)
        addArrowDownImageView(theme)
    }

    private func addDateLabel(_ theme: AlgoStatisticsHeaderViewTheme) {
        dateLabel.customizeAppearance(theme.dateLabel)

        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateStackView.addArrangedSubview(dateLabel)
    }

    private func addArrowDownImageView(_ theme: AlgoStatisticsHeaderViewTheme) {
        arrowDownImageView.customizeAppearance(theme.arrowDown)
        arrowDownImageView.isHidden = true

        dateStackView.addArrangedSubview(arrowDownImageView)
    }
}

extension AlgoStatisticsHeaderView: ViewModelBindable {
    func bindData(_ viewModel: AlgoStatisticsHeaderViewModel?) {
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

protocol AlgoStatisticsHeaderViewDelegate: AnyObject {
    func algoStatisticsHeaderViewDidTapDate(_ view: AlgoStatisticsHeaderView)
}
