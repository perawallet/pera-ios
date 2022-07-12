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

//   AlgoPriceCalculator.swift

import Foundation
import MacaroonUtils

struct AlgoPriceCalculator {
    let algoPriceValues: [AlgoUSDPrice]
    let currencyValue: CurrencyValue?
}

extension AlgoPriceCalculator {
    typealias Price = (amount: Double, currency: Currency)
    
    func calculateRecentPrice() -> Result<Price, AlgoPriceCalculationError> {
        switch currencyValue {
        case .none:
            return .failure(.currencyUnavailable)
        case .available(let currency):
            /// <todo>
            /// Why does the price pass itself as parameter to its function?
            guard let priceValue = algoPriceValues.last else {
                return .failure(.priceFailed)
            }
            
            return calculatePrice(
                priceValue,
                currency
            )
        case .failure:
            return .failure(.currencyFailed)
        }
    }
    
    func calculatePrice(
        _ priceValue: AlgoUSDPrice
    ) -> Result<Price, AlgoPriceCalculationError> {
        switch currencyValue {
        case .none:
            return .failure(.currencyUnavailable)
        case .available(let currency):
            return calculatePrice(
                priceValue,
                currency
            )
        case .failure:
            return .failure(.currencyFailed)
        }
    }
    
    func calculatePriceChangeRate() -> Result<AlgoPriceChangeRate, AlgoPriceCalculationError> {
        switch currencyValue {
        case .none:
            return .failure(.currencyUnavailable)
        case .available(let currency):
            guard
                let basePriceValue = algoPriceValues.last,
                let firstPriceValue = algoPriceValues.first.unwrap({
                    $0.getCurrencyScaledChartOpenValue(with: basePriceValue, for: currency)
                }),
                firstPriceValue > 0,
                let lastPriceValue = algoPriceValues.last.unwrap({
                    $0.getCurrencyScaledChartHighValue(with: basePriceValue, for: currency)
                })
            else {
                return .success(.same)
            }
            
            /// <todo>
            /// Move it to `Macaroon` library.
            let rate = (lastPriceValue - firstPriceValue) / firstPriceValue
            
            let priceChangeRate: AlgoPriceChangeRate
            switch rate {
            case ..<0: priceChangeRate = .decreased(rate * -1)
            case 0: priceChangeRate = .same
            default: priceChangeRate = .increased(rate)
            }
            
            return .success(priceChangeRate)
        case .failure:
            return .failure(.currencyFailed)
        }
    }
}

extension AlgoPriceCalculator {
    private func calculatePrice(
        _ priceValue: AlgoUSDPrice,
        _ currency: Currency
    ) -> Result<Price, AlgoPriceCalculationError> {
        guard let basePriceValue = algoPriceValues.last else {
            return .failure(.priceFailed)
        }
        
        return priceValue
            .getCurrencyScaledChartHighValue(
                with: basePriceValue,
                for: currency
            )
            .unwrap { .success(($0, currency)) } ?? .failure(.priceFailed)
    }
}

enum AlgoPriceChangeRate {
    case increased(Double)
    case same
    case decreased(Double)
}

enum AlgoPriceCalculationError: Error {
    case currencyUnavailable
    case currencyFailed
    case priceFailed
    
    var isAvailable: Bool {
        switch self {
        case .currencyUnavailable: return false
        default: return true
        }
    }
}
