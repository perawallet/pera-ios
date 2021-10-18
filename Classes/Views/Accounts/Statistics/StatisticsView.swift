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
//   StatisticsView.swift

import UIKit
import Macaroon

final class StatisticsView: View {
    weak var delegate: StatisticsViewDelegate?

    private lazy var theme = StatisticsViewTheme()
    private lazy var titleView = MainHeaderView()
    private lazy var statisticsHeaderView = StatisticsHeaderView()
    private lazy var lineChartView = AlgorandChartView(chartCustomizer: AlgoUSDValueChartCustomizer())
    private lazy var statisticsFooterView = StatisticsFooterView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
        linkInteractors()
    }

    func customize(_ theme: StatisticsViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleView(theme)
        addStatisticsHeaderView(theme)
        addLineChartView(theme)
        addStatisticsFooterView(theme)
    }

    func prepareLayout(_ layoutSheet: StatisticsViewTheme) {}

    func customizeAppearance(_ styleSheet: StatisticsViewTheme) {}

    func linkInteractors() {
        statisticsHeaderView.delegate = self
        lineChartView.delegate = self
    }
}

extension StatisticsView {
    private func addTitleView(_ theme: StatisticsViewTheme) {
        titleView.setTitle("title-algorand".localized)
        titleView.setQRButtonHidden(true)
        titleView.setAddButtonHidden(true)
        titleView.setTestNetLabelHidden(true)
        titleView.backgroundColor = AppColors.Shared.System.background.color

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
        }
    }

    private func addStatisticsHeaderView(_ theme: StatisticsViewTheme) {
        addSubview(statisticsHeaderView)
        statisticsHeaderView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.headerHorizontalInset)
            $0.top.equalTo(titleView.snp.bottom).offset(theme.headerTopInset)
        }
    }

    private func addLineChartView(_ theme: StatisticsViewTheme) {
        addSubview(lineChartView)
        lineChartView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(theme.chartHeight)
            $0.top.equalTo(statisticsHeaderView.snp.bottom).offset(theme.chartVerticalInset)
        }
    }

    private func addStatisticsFooterView(_ theme: StatisticsViewTheme) {
        addSubview(statisticsFooterView)
        statisticsFooterView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.footerViewPaddings.leading)
            $0.trailing.equalToSuperview().inset(theme.footerViewPaddings.trailing)
            $0.top.equalTo(lineChartView.snp.bottom).offset(theme.footerViewPaddings.top)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

extension StatisticsView: AlgorandChartViewDelegate {
    func algorandChartView(_ algorandChartView: AlgorandChartView, didSelectItemAt index: Int) {
        delegate?.statisticsView(self, didSelectItemAt: index)
    }

    func algorandChartViewDidDeselect(_ algorandChartView: AlgorandChartView) {
        delegate?.statisticsViewDidDeselect(self)
    }
}

extension StatisticsView: AlgoAnalyticsHeaderViewDelegate {
    func algoAnalyticsHeaderViewDidTapDate(_ view: StatisticsHeaderView) {
        delegate?.statisticsViewDidTapDate(self)
    }
}

extension StatisticsView {
    func bind(_ viewModel: StatisticsViewModel) {
        if let headerViewModel = viewModel.headerViewModel {
            statisticsHeaderView.bindData(headerViewModel)
        }

        if let chartViewModel = viewModel.chartViewModel {
            lineChartView.bind(chartViewModel)
        }

        if let footerViewModel = viewModel.footerViewModel {
            statisticsFooterView.bindData(footerViewModel)
        }
    }

    func bind(_ viewModel: StatisticsHeaderViewModel) {
        statisticsHeaderView.bindData(viewModel)
    }
}

protocol StatisticsViewDelegate: AnyObject {
    func statisticsView(_ view: StatisticsView, didSelectItemAt index: Int)
    func statisticsViewDidDeselect(_ view: StatisticsView)
    func statisticsViewDidTapDate(_ view: StatisticsView)
}
