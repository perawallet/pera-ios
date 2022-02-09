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
//   AlgoStatisticsDataController.swift

import UIKit
import MagpieCore

final class AlgoStatisticsDataController {
    weak var delegate: AlgoStatisticsDataControllerDelegate?

    private let chartDispatchGroup = DispatchGroup()

    private var values: [AlgosUSDValue] = []
    private var lastFiveMinutesValues: AlgosUSDValue?

    private var ongoingEndpointForIntervalValues: EndpointOperatable?
    private var ongoingEndpointForIntervalLastFiveMinutesValues: EndpointOperatable?

    private let api: ALGAPI?

    init(api: ALGAPI?) {
        self.api = api
    }
}

extension AlgoStatisticsDataController {
    func getChartData(for interval: AlgosUSDValueInterval) {
        fetchData(for: interval)
        fetchDataForLastFiveMinutes()

        chartDispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else {
                return
            }

            self.addLastFiveMinutesToValuesIfNeeded(for: interval)
            self.delegate?.algoStatisticsDataController(self, didFetch: self.values)
        }
    }

    private func fetchData(for interval: AlgosUSDValueInterval) {
        chartDispatchGroup.enter()

        ongoingEndpointForIntervalValues = api?.fetchAlgosUSDValue(
            AlgosUSDValueQuery(valueInterval: interval),
            queue: .global(qos: .background)
        ) {
            [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(result):
                self.values = result.history
            case .failure:
                self.delegate?.algoStatisticsDataControllerDidFailToFetch(self)
            }

            self.chartDispatchGroup.leave()
        }
    }

    /// <note>
    /// Fetch last five minute data to display the latest value on the chart.
    private func fetchDataForLastFiveMinutes() {
        chartDispatchGroup.enter()

        ongoingEndpointForIntervalLastFiveMinutesValues = api?.fetchAlgosUSDValue(
            AlgosUSDValueQuery(valueInterval: .hourly),
            queue: .global(qos: .background)
        ) {
            [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(result):
                self.lastFiveMinutesValues = result.history.last
            case .failure:
                self.delegate?.algoStatisticsDataControllerDidFailToFetch(self)
            }

            self.chartDispatchGroup.leave()
        }
    }

    private func addLastFiveMinutesToValuesIfNeeded(for interval: AlgosUSDValueInterval) {
        if let lastFiveMinutesValues = lastFiveMinutesValues {
            let hasSameInterval = values.last?.timestamp == lastFiveMinutesValues.timestamp
            if !hasSameInterval {
                values.append(lastFiveMinutesValues)
            }
        }
    }
}

extension AlgoStatisticsDataController {
    func cancel() {
        ongoingEndpointForIntervalValues?.cancel()
        ongoingEndpointForIntervalValues = nil

        ongoingEndpointForIntervalLastFiveMinutesValues?.cancel()
        ongoingEndpointForIntervalLastFiveMinutesValues = nil
    }
}

protocol AlgoStatisticsDataControllerDelegate: AnyObject {
    func algoStatisticsDataController(_ dataController: AlgoStatisticsDataController, didFetch values: [AlgosUSDValue])
    func algoStatisticsDataControllerDidFailToFetch(_ dataController: AlgoStatisticsDataController)
}
