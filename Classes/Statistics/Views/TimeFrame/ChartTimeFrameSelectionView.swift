// Copyright 2022 Pera Wallet, LDA

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
//   ChartTimeFrameSelectionView.swift

import UIKit
import MacaroonUIKit

final class ChartTimeFrameSelectionView: View {
    weak var delegate: ChartTimeFrameSelectionViewDelegate?

    private lazy var theme = ChartTimeFrameSelectionViewTheme()

    private lazy var stackView = UIStackView()

    private lazy var dailyButton = MacaroonUIKit.Button()
    private lazy var weeklyButton = MacaroonUIKit.Button()
    private lazy var monthlyButton = MacaroonUIKit.Button()
    private lazy var yearlyButton = MacaroonUIKit.Button()
    private lazy var allTimeButton = MacaroonUIKit.Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
        setListeners()
    }

    func setListeners() {
        dailyButton.addTarget(self, action: #selector(didTapDailyButton), for: .touchUpInside)
        weeklyButton.addTarget(self, action: #selector(didTapWeeklyButton), for: .touchUpInside)
        monthlyButton.addTarget(self, action: #selector(didTapMonthlyButton), for: .touchUpInside)
        yearlyButton.addTarget(self, action: #selector(didTapYearlyButton), for: .touchUpInside)
        allTimeButton.addTarget(self, action: #selector(didTapAllTimeButton), for: .touchUpInside)
    }

    func customize(_ theme: ChartTimeFrameSelectionViewTheme) {
        addStackView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension ChartTimeFrameSelectionView {
    private func addStackView(_ theme: ChartTimeFrameSelectionViewTheme) {
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = theme.stackViewSpacing

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        [
            dailyButton,
            weeklyButton,
            monthlyButton,
            yearlyButton,
            allTimeButton
        ].enumerated().forEach {
            $1.customizeAppearance(theme.buttonStyle)
            $1.draw(corner: theme.buttonCorner)

            $1.setTitle(
                AlgosUSDValueInterval.casesOtherThanHourly[$0].toStringForChartTimeFrameSelection(),
                for: .normal
            )

            stackView.addArrangedSubview($1)
        }

        toggleButton(dailyButton, isSelected: true)
    }
}

extension ChartTimeFrameSelectionView {
    @objc
    private func didTapDailyButton() {
        notifyDelegateForSelectedTimeInterval(button: dailyButton, timeInterval: .daily)
    }

    @objc
    private func didTapWeeklyButton() {
        notifyDelegateForSelectedTimeInterval(button: weeklyButton, timeInterval: .weekly)
    }

    @objc
    private func didTapMonthlyButton() {
        notifyDelegateForSelectedTimeInterval(button: monthlyButton, timeInterval: .monthly)
    }

    @objc
    private func didTapYearlyButton() {
        notifyDelegateForSelectedTimeInterval(button: yearlyButton, timeInterval: .yearly)
    }

    @objc
    private func didTapAllTimeButton() {
        notifyDelegateForSelectedTimeInterval(button: allTimeButton, timeInterval: .all)
    }

    private func notifyDelegateForSelectedTimeInterval(button: UIButton, timeInterval: AlgosUSDValueInterval) {
        clearButtonSelections()
        delegate?.chartTimeFrameSelectionView(self, didSelect: timeInterval)
        toggleButton(button, isSelected: true)
    }

    private func clearButtonSelections() {
        [
            dailyButton,
            weeklyButton,
            monthlyButton,
            yearlyButton,
            allTimeButton
        ].forEach {
            toggleButton($0, isSelected: false)
        }
    }

    private func toggleButton(_ button: UIButton, isSelected: Bool) {
        button.isSelected = isSelected
        button.backgroundColor = button.isSelected ? theme.selectedButtonBackgroundColor.uiColor : .clear
    }
}

protocol ChartTimeFrameSelectionViewDelegate: AnyObject {
    func chartTimeFrameSelectionView(_ view: ChartTimeFrameSelectionView, didSelect timeInterval: AlgosUSDValueInterval)
}
