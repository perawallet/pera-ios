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
//   AlgoUSDPriceChange.swift

import Foundation

struct AlgoUSDPriceChange {
    let firstPrice: AlgosUSDValue?
    let lastPrice: AlgosUSDValue?
    let selectedPrice: AlgosUSDValue?

    func getValueChangeStatus() -> ValueChangeStatus {
        // Use the opening value of the first price and closing value of the last price in the interval to calculate change amount.
        guard let firstPrice = firstPrice?.open,
              let lastPrice = lastPrice?.close else {
            return .increased
        }

        if firstPrice > lastPrice {
            return .decreased
        } else if lastPrice > firstPrice {
            return .increased
        } else {
            return .stable
        }
    }

    func getValueChangePercentage() -> Double {
        // Use the opening value of the first price and closing value of the last price in the interval to calculate change amount.
        guard let firstPrice = firstPrice?.open,
              let lastPrice = lastPrice?.close else {
            return 1
        }

        return lastPrice / firstPrice
    }
}
