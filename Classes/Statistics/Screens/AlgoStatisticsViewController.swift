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
//   AlgoStatisticsViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit
import MacaroonUtils

final class AlgoStatisticsViewController: BaseScrollViewController {
    override var prefersLargeTitle: Bool {
        return true
    }

    private lazy var algoStatisticsView = AlgoStatisticsView()
    private lazy var loadingView = AlgoStatisticsLoadingView()

    private lazy var algoStatisticsDataController = AlgoStatisticsDataController(api: api)

    private var cachedAlgoStatisticsViewModels: [AlgosUSDValueInterval: AlgoStatisticsViewModel] = [:]

    private var chartEntries: [AlgosUSDValue]?
    private var selectedTimeInterval: AlgosUSDValueInterval = .daily

    private var currency: Currency? {
        return sharedDataController.currency.value
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        algoStatisticsView.isHidden = true
        getChartData(for: .daily)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isViewFirstLoaded {
            getChartData(for: selectedTimeInterval)
        }
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "title-algorand".localized
    }

    override func prepareLayout() {
        super.prepareLayout()
        addLoadingView()
        addAlgoStatisticsView()
    }

    override func linkInteractors() {
        super.linkInteractors()
        algoStatisticsView.delegate = self
        algoStatisticsDataController.delegate = self
    }
}

extension AlgoStatisticsViewController {
    private func addLoadingView() {
        loadingView.customize(AlgoStatisticsLoadingViewTheme())

        contentView.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addAlgoStatisticsView() {
        contentView.addSubview(algoStatisticsView)
        algoStatisticsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AlgoStatisticsViewController {    
    private func getChartData(for interval: AlgosUSDValueInterval) {
        algoStatisticsDataController.cancel()

        algoStatisticsView.clearLineChart()
        algoStatisticsView.startLoading()

        if let cachedStatisticsViewModel = cachedAlgoStatisticsViewModels[interval] {
            algoStatisticsView.stopLoading()

            chartEntries = cachedStatisticsViewModel.values
            bindView(with: cachedStatisticsViewModel)
            return
        }


        algoStatisticsDataController.getChartData(for: interval)
    }
}

extension AlgoStatisticsViewController: AlgoStatisticsViewDelegate {
    func algoStatisticsView(_ view: AlgoStatisticsView, didSelect timeInterval: AlgosUSDValueInterval) {
        guard selectedTimeInterval != timeInterval else {
            return
        }

        selectedTimeInterval = timeInterval
        getChartData(for: timeInterval)
    }

    func algoStatisticsView(_ view: AlgoStatisticsView, didSelectItemAt index: Int) {
        guard let currency = currency,
              let values = chartEntries,
              !values.isEmpty,
              let selectedPrice = values[safe: index] else {
                  return
              }

        bindHeaderView(
            values: values,
            selectedPrice: selectedPrice,
            timerInterval: selectedTimeInterval,
            currency: currency
        )
    }
    
    func algoStatisticsViewDidDeselect(_ view: AlgoStatisticsView) {
        guard let currency = currency,
              let values = chartEntries,
              !values.isEmpty else {
                  return
              }

        bindHeaderView(
            values: values,
            selectedPrice: nil,
            timerInterval: selectedTimeInterval,
            currency: currency
        )
    }

    private func bindHeaderView(
        values: [AlgosUSDValue],
        selectedPrice: AlgosUSDValue?,
        timerInterval: AlgosUSDValueInterval,
        currency: Currency
    ) {
        let priceChange = AlgoUSDPriceChange(
            firstPrice: values.first,
            lastPrice: values.last,
            selectedPrice: selectedPrice,
            currency: currency
        )

        algoStatisticsView.bind(
            AlgoStatisticsHeaderViewModel(
                priceChange: priceChange,
                timeInterval: timerInterval,
                currency: currency
            )
        )
    }
}

extension AlgoStatisticsViewController: AlgoStatisticsDataControllerDelegate {
    func algoStatisticsDataController(
        _ dataController: AlgoStatisticsDataController,
        didFetch values: [AlgosUSDValue]
    ) {
        chartEntries = values

        guard let currency = currency else {
            /// <todo>
            /// Screen stays on loading if currency is nil.
            return
        }

        createAlgoStatisticViewModel(
            values: values,
            timeInterval: selectedTimeInterval,
            currency: currency
        ) {
            [weak self] algoStatisticViewModel in
            guard let self = self else {
                return
            }

            self.algoStatisticsView.stopLoading()
            self.bindView(with: algoStatisticViewModel)
        }
    }

    func algoStatisticsDataControllerDidFailToFetch(_ dataController: AlgoStatisticsDataController) {
        chartEntries = nil
    }
}

extension AlgoStatisticsViewController {
    private func bindView(with algoStatisticViewModel: AlgoStatisticsViewModel) {
        algoStatisticsView.isHidden = false
        loadingView.isHidden = true

        algoStatisticsView.bind(algoStatisticViewModel)
    }
}

extension AlgoStatisticsViewController {
    func createAlgoStatisticViewModel(
        values: [AlgosUSDValue],
        timeInterval: AlgosUSDValueInterval,
        currency: Currency,
        then handler: @escaping (AlgoStatisticsViewModel) -> Void
    ) {
        let priceChange = AlgoUSDPriceChange(
            firstPrice: values.first,
            lastPrice: values.last,
            selectedPrice: nil,
            currency: currency
        )

        let algoStatisticViewModel = AlgoStatisticsViewModel(
            values: values,
            priceChange: priceChange,
            timeInterval: timeInterval,
            currency: currency
        )

        asyncMain {
            [weak self] in
            guard let self = self else {
                return
            }

            self.cacheAlgoStatisticsViewModel(algoStatisticViewModel, for: timeInterval)
            handler(algoStatisticViewModel)
        }
    }

    private func cacheAlgoStatisticsViewModel(
        _ algoStatisticViewModel: AlgoStatisticsViewModel,
        for timeInterval: AlgosUSDValueInterval
    ) {
        cachedAlgoStatisticsViewModels[timeInterval] = algoStatisticViewModel
    }
}
