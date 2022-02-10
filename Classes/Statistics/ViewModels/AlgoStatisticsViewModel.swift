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
//   AlgoStatisticsViewModel.swift

import UIKit
import MacaroonUIKit

final class AlgoStatisticsViewModel: ViewModel {
    private(set) var headerViewModel: AlgoStatisticsHeaderViewModel?
    private(set) var chartViewModel: AlgosUSDChartViewModel?
    private(set) var footerViewModel: AlgoStatisticsFooterViewModel?

    init(
        values: [AlgosUSDValue],
        priceChange: AlgoUSDPriceChange,
        timeInterval: AlgosUSDValueInterval,
        currency: Currency
    ) {
        bindHeaderViewModel(from: priceChange, and: timeInterval, and: currency)
        bindChartViewModel(from: values, and: priceChange, and: currency)
        bindFooterViewModel(from: priceChange, and: timeInterval, and: currency)
    }

    private func bindHeaderViewModel(
        from priceChange: AlgoUSDPriceChange,
        and timeInterval: AlgosUSDValueInterval,
        and currency: Currency
    ) {
        headerViewModel = AlgoStatisticsHeaderViewModel(
            priceChange: priceChange,
            timeInterval: timeInterval,
            currency: currency
        )
    }

    private func bindChartViewModel(
        from values: [AlgosUSDValue],
        and priceChange: AlgoUSDPriceChange,
        and currency: Currency
    ) {
        chartViewModel = AlgosUSDChartViewModel(
            valueChangeStatus: priceChange.getValueChangeStatus(),
            values: values,
            currency: currency
        )
    }

    private func bindFooterViewModel(
        from priceChange: AlgoUSDPriceChange,
        and timeInterval: AlgosUSDValueInterval,
        and currency: Currency
    ) {
        // <todo>
        // Remove Mock Data
        footerViewModel = AlgoStatisticsFooterViewModel()
    }
}
