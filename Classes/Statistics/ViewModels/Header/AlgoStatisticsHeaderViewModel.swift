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

//   AlgoStatisticsHeaderViewModel.swift

import UIKit
import SwiftDate
import MacaroonUIKit

final class AlgoStatisticsHeaderViewModel: ViewModel {
    private(set) var amount: String?
    private(set) var isValueChangeDisplayed = true
    private(set) var valueChangeViewModel: AlgoStatisticsValueChangeViewModel?
    private(set) var date: String?

    private let priceChange: AlgoUSDPriceChange?

    var isDateHidden: Bool {
        priceChange?.selectedPrice == nil
    }

    init(priceChange: AlgoUSDPriceChange, timeInterval: AlgosUSDValueInterval, currency: Currency) {
        self.priceChange = priceChange

        bindAmount(from: priceChange, and: currency)
        bindIsValueChangeDisplayed(from: priceChange)
        bindValueChangeViewModel(from: priceChange)
        bindDate(from: priceChange, and: timeInterval)
    }
}

extension AlgoStatisticsHeaderViewModel {
    private func bindAmount(from priceChange: AlgoUSDPriceChange, and currency: Currency) {
        guard let currentAlgosUSDValue = priceChange.lastPrice else {
            return
        }

        if let selectedPrice = priceChange.selectedPrice?.getCurrencyScaledChartHighValue(with: currentAlgosUSDValue, for: currency),
           let currencyValue = selectedPrice.toCurrencyStringForLabel {
            amount = "\(currencyValue) \(currency.id)"
            return
        }

        if let currentPrice = priceChange.lastPrice?.getCurrencyScaledChartHighValue(with: currentAlgosUSDValue, for: currency),
           let currencyValue = currentPrice.toCurrencyStringForLabel {
            amount = "\(currencyValue) \(currency.id)"
        }
    }

    private func bindIsValueChangeDisplayed(from priceChange: AlgoUSDPriceChange) {
        // Do not show the value change percentage if a value is selected or it's same as comparision.
        isValueChangeDisplayed = priceChange.selectedPrice == nil && priceChange.getValueChangeStatus() != .stable
    }

    private func bindValueChangeViewModel(from priceChange: AlgoUSDPriceChange) {
        valueChangeViewModel = AlgoStatisticsValueChangeViewModel(priceChange)
    }

    private func bindDate(from priceChange: AlgoUSDPriceChange, and timeInterval: AlgosUSDValueInterval) {
        if let selectedPrice = priceChange.selectedPrice,
           let timestamp = selectedPrice.timestamp {
            date = Date(timeIntervalSince1970: timestamp).toFormat("MMMM dd, yyyy - HH:mm")
            return
        }

        date = timeInterval.toString()
    }
}
