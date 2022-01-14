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
//   StatisticsFooterViewModel.swift

import Foundation
import MacaroonUIKit

final class AlgoStatisticsFooterViewModel {
    private(set) var previousCloseViewModel: AlgoStatisticsInfoViewModel?
    private(set) var openViewModel: AlgoStatisticsInfoViewModel?

    init(
        priceChange: AlgoUSDPriceChange,
        timeInterval: AlgosUSDValueInterval,
        currency: Currency
    ) {
        bindPreviousCloseViewModel(from: priceChange)
        bindOpenViewModel(from: priceChange)
    }
}

extension AlgoStatisticsFooterViewModel {
    private func bindPreviousCloseViewModel(from priceChange: AlgoUSDPriceChange) {
        guard let openPrice = priceChange.firstPrice?.open,
              let price = openPrice.toCurrencyStringForLabel else {
            return
        }

        previousCloseViewModel = AlgoStatisticsInfoViewModel(title: "algo-statistics-previous-close".localized, value: "\(price)")
    }
    private func bindOpenViewModel(from priceChange: AlgoUSDPriceChange) {
        guard let openPrice = priceChange.firstPrice?.open,
              let price = openPrice.toCurrencyStringForLabel else {
            return
        }

        openViewModel = AlgoStatisticsInfoViewModel(title: "algo-statistics-open".localized, value: "\(price)")
    }
}
