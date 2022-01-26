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
//   AlgoStatisticsViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class AlgoStatisticsViewController: BaseScrollViewController {
    override var prefersLargeTitle: Bool {
        return true
    }

    private lazy var filterOptionsTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var theme = Theme()
    private lazy var algoStatisticsView = AlgoStatisticsView()

    private lazy var algoStatisticsDataController = AlgoStatisticsDataController(api: api)

    private var chartEntries: [AlgosUSDValue]?
    private var selectedTimeInterval: AlgosUSDValueInterval = .daily

    private var currency: Currency?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrency { [weak self] in
            self?.getChartData()
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
        addAlgoStatisticsView()
    }

    override func linkInteractors() {
        super.linkInteractors()
        algoStatisticsView.delegate = self
        algoStatisticsDataController.delegate = self
    }
}

extension AlgoStatisticsViewController {
    private func addAlgoStatisticsView() {
        contentView.addSubview(algoStatisticsView)
        algoStatisticsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AlgoStatisticsViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        .preferred(theme.modalHeight)
    }
}

extension AlgoStatisticsViewController {
    private func fetchCurrency(then completion: @escaping () -> Void) {
        algoStatisticsDataController.getCurrency { [weak self] currency in
            if let currency = currency {
                self?.currency = currency
                completion()
            }
        }
    }
    
    private func getChartData(for interval: AlgosUSDValueInterval = .daily) {
        algoStatisticsDataController.getChartData(for: interval)
    }
}

extension AlgoStatisticsViewController: AlgoStatisticsViewDelegate {
    func algoStatisticsView(_ view: AlgoStatisticsView, didSelect timeInterval: AlgosUSDValueInterval) {
        selectedTimeInterval = timeInterval
        getChartData(for: timeInterval)
    }

    func algoStatisticsViewDidTapDate(_ view: AlgoStatisticsView) {
        filterOptionsTransition.perform(
            .algoStatisticsDateSelection(option: selectedTimeInterval, delegate: self),
            by: .presentWithoutNavigationController
        )
    }

    func algoStatisticsView(_ view: AlgoStatisticsView, didSelectItemAt index: Int) {
        guard let values = chartEntries,
              !values.isEmpty,
              let selectedPrice = values[safe: index] else {
                  return
              }

        bindHeaderView(with: values, selectedPrice: selectedPrice)
    }
    
    func algoStatisticsViewDidDeselect(_ view: AlgoStatisticsView) {
        guard let values = chartEntries,
              !values.isEmpty else {
                  return
              }

        bindHeaderView(with: values, selectedPrice: nil)
    }

    private func bindHeaderView(with values: [AlgosUSDValue], selectedPrice: AlgosUSDValue?) {
        guard let currency = currency else {
            return
        }

        let priceChange = AlgoUSDPriceChange(
            firstPrice: values.first,
            lastPrice: values.last,
            selectedPrice: selectedPrice,
            currency: currency
        )
        algoStatisticsView.bind(
            AlgoStatisticsHeaderViewModel(
                priceChange: priceChange,
                timeInterval: selectedTimeInterval,
                currency: currency
            )
        )
    }
}

extension AlgoStatisticsViewController: AlgoStatisticsDateSelectionViewControllerDelegate {
    func algoStatisticsDateSelectionViewController(
        _ algoStatisticsDateSelectionViewController: AlgoStatisticsDateSelectionViewController,
        didSelect selectedOption: AlgosUSDValueInterval
    ) {
        selectedTimeInterval = selectedOption
        getChartData(for: selectedOption)
    }
}

extension AlgoStatisticsViewController: AlgoStatisticsDataControllerDelegate {
    func algoStatisticsDataController(_ dataController: AlgoStatisticsDataController, didFetch values: [AlgosUSDValue]) {
        chartEntries = values
        bindView(with: values)
    }

    func algoStatisticsDataControllerDidFailToFetch(_ dataController: AlgoStatisticsDataController) {
        chartEntries = nil
    }

    private func bindView(with values: [AlgosUSDValue]) {
        guard let currency = currency else {
            return
        }

        let priceChange = AlgoUSDPriceChange(firstPrice: values.first, lastPrice: values.last, selectedPrice: nil, currency: currency)
        algoStatisticsView.bind(
            AlgoStatisticsViewModel(
                values: values,
                priceChange: priceChange,
                timeInterval: selectedTimeInterval,
                currency: currency
            )
        )
    }
}
