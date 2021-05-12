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
//   AlgoUSDAnalyticsDataController.swift

import UIKit

class AlgoUSDAnalyticsDataController {

    weak var delegate: AlgoUSDAnalyticsDataControllerDelegate?

    private let api: AlgorandAPI?

    init(api: AlgorandAPI?) {
        self.api = api
    }

    func getChartData(for interval: AlgosUSDValueInterval) {
        api?.fetchAlgosUSDValue(with: AlgosUSDValueQuery(valueInterval: interval)) { [weak self ]response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(result):
                self.delegate?.algoUSDAnalyticsDataController(self, didFetch: result.history)
            case .failure:
                self.delegate?.algoUSDAnalyticsDataControllerDidFailToFetch(self)
            }
        }
    }
}

protocol AlgoUSDAnalyticsDataControllerDelegate: class {
    func algoUSDAnalyticsDataController(_ dataController: AlgoUSDAnalyticsDataController, didFetch values: [AlgosUSDValue])
    func algoUSDAnalyticsDataControllerDidFailToFetch(_ dataController: AlgoUSDAnalyticsDataController)
}
