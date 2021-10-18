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
//   StatisticsViewController.swift

import UIKit

final class StatisticsViewController: BaseScrollViewController {
    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var filterOptionsPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(theme.dateSelectionModalHeight))
    )

    private lazy var theme = Theme()
    private lazy var statisticsView = StatisticsView()

    private lazy var dataController = StatisticsDataController(api: api)
    private lazy var assetCardDisplayDataController: AssetCardDisplayDataController = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return AssetCardDisplayDataController(api: api)
    }()
    
    private var chartEntries: [AlgosUSDValue]?
    private var selectedTimeInterval: AlgosUSDValueInterval = .hourly

    private var currency: Currency?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrency { [weak self] in
            self?.getChartData()
        }
    }

    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addStatisticsView()
    }

    override func linkInteractors() {
        super.linkInteractors()
        statisticsView.delegate = self
        dataController.delegate = self
    }
}

extension StatisticsViewController {
    private func addStatisticsView() {
        contentView.addSubview(statisticsView)
        statisticsView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.safeEqualToTop(of: self)
        }
    }
}

extension StatisticsViewController {
    private func fetchCurrency(then completion: @escaping () -> Void) {
        assetCardDisplayDataController.getCurrency { [weak self] currency in
            if let currency = currency {
                self?.currency = currency
                completion()
            }
        }
    }
    
    private func getChartData(for interval: AlgosUSDValueInterval = .hourly) {
        dataController.getChartData(for: interval)
    }
}

extension StatisticsViewController: StatisticsViewDelegate {
    func statisticsViewDidTapDate(_ view: StatisticsView) {
        let controller = open(
            .dateSelection(option: selectedTimeInterval),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: filterOptionsPresenter
            )
        ) as? StatisticsDateSelectionViewController

        controller?.delegate = self
    }

    func statisticsView(_ view: StatisticsView, didSelectItemAt index: Int) {
        guard let values = chartEntries,
              !values.isEmpty,
              let selectedPrice = values[safe: index] else { return }

        bindHeaderView(with: values, selectedPrice: selectedPrice)
    }
    
    func statisticsViewDidDeselect(_ view: StatisticsView) {
        guard let values = chartEntries,
              !values.isEmpty else { return }

        bindHeaderView(with: values, selectedPrice: nil)
    }

    private func bindHeaderView(with values: [AlgosUSDValue], selectedPrice: AlgosUSDValue?) {
        guard let currency = currency else { return }

        let priceChange = AlgoUSDPriceChange(
            firstPrice: values.first,
            lastPrice: values.last,
            selectedPrice: selectedPrice,
            currency: currency
        )
        statisticsView.bind(
            StatisticsHeaderViewModel(
                priceChange: priceChange,
                timeInterval: selectedTimeInterval,
                currency: currency
            )
        )
    }
}

extension StatisticsViewController: StatisticsDateSelectionViewControllerDelegate {
    func statisticsDateSelectionViewController(
        _ statisticsDateSelectionViewController: StatisticsDateSelectionViewController,
        didSelect selectedOption: AlgosUSDValueInterval
    ) {
        selectedTimeInterval = selectedOption
        getChartData(for: selectedOption)
    }
}

extension StatisticsViewController: StatisticsDataControllerDelegate {
    func statisticsDataController(_ dataController: StatisticsDataController, didFetch values: [AlgosUSDValue]) {
        chartEntries = values
        bindView(with: values)
    }

    func statisticsDataControllerDidFailToFetch(_ dataController: StatisticsDataController) {
        chartEntries = nil
    }

    private func bindView(with values: [AlgosUSDValue]) {
        guard let currency = currency else { return }

        let priceChange = AlgoUSDPriceChange(firstPrice: values.first, lastPrice: values.last, selectedPrice: nil, currency: currency)
        statisticsView.bind(
            StatisticsViewModel(
                values: values,
                priceChange: priceChange,
                timeInterval: selectedTimeInterval,
                currency: currency
            )
        )
    }
}
