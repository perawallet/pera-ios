// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   TendenciesViewModel.swift

import pera_wallet_core
import MacaroonUIKit

final class TendenciesViewModel {
    private let currency: CurrencyProvider?
    private let chartData: [ChartDataPointViewModel]?
    
    var differenceText: TextProvider?
    var differenceInPercentageText: TextProvider?
    var arrowImageView: ImageProvider?
    
    init(
        chartData: [ChartDataPointViewModel]?,
        currency: CurrencyProvider?,
    ) {
        self.chartData = chartData
        self.currency = currency
        
        configure()
    }
    
    private func configure() {
        guard
            let chartData,
            chartData.count > 1,
            let firstValue = chartData.first?.value,
            let lastValue = chartData.last?.value,
            firstValue != lastValue
        else {
            return
        }
        
        let difference = lastValue - firstValue
        let isPositive = difference > 0
        let textSign = isPositive ? "+" : "-"
        let textColor = isPositive ? Colors.Helpers.positive : Colors.Helpers.negative
        
        guard let rawCurrency = try? currency?.fiatValue?.unwrap() else { return }
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = rawCurrency
        
        guard let differenceString = currencyFormatter.format(abs(difference)) else { return }
        
        differenceText = (textSign + differenceString).attributed([
            .font(Typography.bodyMedium()),
            .textColor(textColor)
        ])
        
        if firstValue != 0 {
            let differenceInPercentage = (difference / firstValue) * 100
            if let percentageString = Formatter
                .decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 2)
                .string(for: abs(differenceInPercentage)) {
                differenceInPercentageText = (percentageString + "%").attributed([
                    .font(Typography.bodyMedium()),
                    .textColor(textColor)
                ])
            }
        }
        
        arrowImageView = (isPositive ? "icon-market-increase" : "icon-market-decrease").uiImage
    }
}
