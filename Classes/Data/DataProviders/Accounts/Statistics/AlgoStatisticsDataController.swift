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
<<<<<<< HEAD:Classes/Data/DataProviders/Accounts/Statistics/AlgoStatisticsDataController.swift
//   AlgoStatisticsDataController.swift

import UIKit

final class AlgoStatisticsDataController {
    weak var delegate: AlgoStatisticsDataControllerDelegate?
=======
//   StatisticsDataController.swift

import UIKit

final class StatisticsDataController {
    weak var delegate: StatisticsDataControllerDelegate?
>>>>>>> 44279ccd (✨ Implement algo price):Classes/Data/DataProviders/Accounts/Statistics/StatisticsDataController.swift

    private let chartDispatchGroup = DispatchGroup()

    private var values: [AlgosUSDValue] = []
    private var lastFiveMinutesValues: AlgosUSDValue?

    private let api: AlgorandAPI?

    init(api: AlgorandAPI?) {
        self.api = api
    }

    func getChartData(for interval: AlgosUSDValueInterval) {
        fetchData(for: interval)
        fetchDataForLastFiveMinutes()

        chartDispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else {
                return
            }

            self.addLastFiveMinutesToValuesIfNeeded()
            self.returnValues()
        }
    }

    private func fetchData(for interval: AlgosUSDValueInterval) {
        chartDispatchGroup.enter()

        api?.fetchAlgosUSDValue(with: AlgosUSDValueQuery(valueInterval: interval)) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(result):
                self.values = result.history
            case .failure:
<<<<<<< HEAD:Classes/Data/DataProviders/Accounts/Statistics/AlgoStatisticsDataController.swift
                self.delegate?.algoStatisticsDataControllerDidFailToFetch(self)
=======
                self.delegate?.statisticsDataControllerDidFailToFetch(self)
>>>>>>> 44279ccd (✨ Implement algo price):Classes/Data/DataProviders/Accounts/Statistics/StatisticsDataController.swift
            }

            self.chartDispatchGroup.leave()
        }
    }

    // Fetch last five minute data to display the latest value on the chart.
    private func fetchDataForLastFiveMinutes() {
        chartDispatchGroup.enter()

        api?.fetchAlgosUSDValue(with: AlgosUSDValueQuery(valueInterval: .hourly)) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(result):
                self.lastFiveMinutesValues = result.history.last
            case .failure:
<<<<<<< HEAD:Classes/Data/DataProviders/Accounts/Statistics/AlgoStatisticsDataController.swift
                self.delegate?.algoStatisticsDataControllerDidFailToFetch(self)
=======
                self.delegate?.statisticsDataControllerDidFailToFetch(self)
>>>>>>> 44279ccd (✨ Implement algo price):Classes/Data/DataProviders/Accounts/Statistics/StatisticsDataController.swift
            }

            self.chartDispatchGroup.leave()
        }
    }

    private func addLastFiveMinutesToValuesIfNeeded() {
        if let lastFiveMinutesValues = lastFiveMinutesValues {
            let hasSameInterval = values.last?.timestamp == lastFiveMinutesValues.timestamp
            if !hasSameInterval {
                values.append(lastFiveMinutesValues)
            }
        }
    }

    private func returnValues() {
<<<<<<< HEAD:Classes/Data/DataProviders/Accounts/Statistics/AlgoStatisticsDataController.swift
        delegate?.algoStatisticsDataController(self, didFetch: values)
    }
}

protocol AlgoStatisticsDataControllerDelegate: AnyObject {
    func algoStatisticsDataController(_ dataController: AlgoStatisticsDataController, didFetch values: [AlgosUSDValue])
    func algoStatisticsDataControllerDidFailToFetch(_ dataController: AlgoStatisticsDataController)
=======
        delegate?.statisticsDataController(self, didFetch: values)
    }
}

protocol StatisticsDataControllerDelegate: AnyObject {
    func statisticsDataController(_ dataController: StatisticsDataController, didFetch values: [AlgosUSDValue])
    func statisticsDataControllerDidFailToFetch(_ dataController: StatisticsDataController)
>>>>>>> 44279ccd (✨ Implement algo price):Classes/Data/DataProviders/Accounts/Statistics/StatisticsDataController.swift
}
