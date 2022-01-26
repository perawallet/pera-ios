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
//   AlgoStatisticsView.swift

import UIKit
import MacaroonUIKit

final class AlgoStatisticsView: View {
    weak var delegate: AlgoStatisticsViewDelegate?

    private lazy var theme = AlgoStatisticsViewTheme()
    private lazy var algoStatisticsHeaderView = AlgoStatisticsHeaderView()
    private lazy var lineChartView = AlgorandChartView(chartCustomizer: AlgoUSDValueChartCustomizer())
    private lazy var chartTimeFrameSelectionView = ChartTimeFrameSelectionView()
    private lazy var algoStatisticsFooterView = AlgoStatisticsFooterView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
        linkInteractors()
    }

    func customize(_ theme: AlgoStatisticsViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addAlgoStatisticsHeaderView(theme)
        addLineChartView(theme)
        addChartTimeFrameSelectionView(theme)
        addAlgoStatisticsFooterView(theme)
    }

    func prepareLayout(_ layoutSheet: AlgoStatisticsViewTheme) {}

    func customizeAppearance(_ styleSheet: AlgoStatisticsViewTheme) {}

    func linkInteractors() {
        algoStatisticsHeaderView.delegate = self
        lineChartView.delegate = self
        chartTimeFrameSelectionView.delegate = self
    }
}

extension AlgoStatisticsView {
    private func addAlgoStatisticsHeaderView(_ theme: AlgoStatisticsViewTheme) {
        addSubview(algoStatisticsHeaderView)
        algoStatisticsHeaderView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().offset(theme.headerTopInset)
        }
    }

    private func addLineChartView(_ theme: AlgoStatisticsViewTheme) {
        addSubview(lineChartView)
        lineChartView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(theme.chartHeight)
            $0.top.equalTo(algoStatisticsHeaderView.snp.bottom).offset(theme.chartVerticalInset)
        }
    }

    private func addChartTimeFrameSelectionView(_ theme: AlgoStatisticsViewTheme) {
        addSubview(chartTimeFrameSelectionView)

        chartTimeFrameSelectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(lineChartView.snp.bottom).offset(theme.chartTimeFrameSelectionViewTopPadding)
        }
    }

    private func addAlgoStatisticsFooterView(_ theme: AlgoStatisticsViewTheme) {
        addSubview(algoStatisticsFooterView)
        algoStatisticsFooterView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.footerViewPaddings.leading)
            $0.trailing.equalToSuperview().inset(theme.footerViewPaddings.trailing)
            $0.top.equalTo(chartTimeFrameSelectionView.snp.bottom).offset(theme.footerViewPaddings.top)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

extension AlgoStatisticsView: ChartTimeFrameSelectionViewDelegate {
    func chartTimeFrameSelectionView(_ view: ChartTimeFrameSelectionView, didSelect timeInterval: AlgosUSDValueInterval) {
        delegate?.algoStatisticsView(self, didSelect: timeInterval)
    }
}


extension AlgoStatisticsView: AlgorandChartViewDelegate {
    func algorandChartView(_ algorandChartView: AlgorandChartView, didSelectItemAt index: Int) {
        delegate?.algoStatisticsView(self, didSelectItemAt: index)
    }

    func algorandChartViewDidDeselect(_ algorandChartView: AlgorandChartView) {
        delegate?.algoStatisticsViewDidDeselect(self)
    }
}

extension AlgoStatisticsView: AlgoStatisticsHeaderViewDelegate {
    func algoStatisticsHeaderViewDidTapDate(_ view: AlgoStatisticsHeaderView) {
        delegate?.algoStatisticsViewDidTapDate(self)
    }
}

extension AlgoStatisticsView {
    func bind(_ viewModel: AlgoStatisticsViewModel) {
        if let headerViewModel = viewModel.headerViewModel {
            algoStatisticsHeaderView.bindData(headerViewModel)
        }

        if let chartViewModel = viewModel.chartViewModel {
            lineChartView.bind(chartViewModel)
        }

        if let footerViewModel = viewModel.footerViewModel {
            algoStatisticsFooterView.bindData(footerViewModel)
        }
    }

    func bind(_ viewModel: AlgoStatisticsHeaderViewModel) {
        algoStatisticsHeaderView.bindData(viewModel)
    }
}

protocol AlgoStatisticsViewDelegate: AnyObject {
    func algoStatisticsView(_ view: AlgoStatisticsView, didSelect timeInterval: AlgosUSDValueInterval)
    func algoStatisticsView(_ view: AlgoStatisticsView, didSelectItemAt index: Int)
    func algoStatisticsViewDidDeselect(_ view: AlgoStatisticsView)
    func algoStatisticsViewDidTapDate(_ view: AlgoStatisticsView)
}
