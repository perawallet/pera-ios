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
//   PortfolioCalculator.swift

import Foundation

/// <todo>
/// Rethink this approach later.
protocol PortfolioCalculator {
    func calculateCoinsValue(
        _ accounts: [AccountHandle],
        as currency: CurrencyHandle
    ) -> PortfolioHandle
    func calculateAssetsValue(
        _ accounts: [AccountHandle],
        as currency: CurrencyHandle
    ) -> PortfolioHandle
}

extension PortfolioCalculator {
    func calculateTotalValue(
        _ accounts: [AccountHandle],
        as currency: CurrencyHandle
    ) -> PortfolioHandle {
        let coinsValueResult = calculateCoinsValue(
            accounts,
            as: currency
        )
        
        switch coinsValueResult {
        case .success:
            let assetsValueResult = calculateAssetsValue(
                accounts,
                as: currency
            )
            return calculateTotalValue(
                coinsValueResult: coinsValueResult,
                assetsValueResult: assetsValueResult
            )
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func calculateTotalValue(
        coinsValueResult: PortfolioHandle,
        assetsValueResult: PortfolioHandle
    ) -> PortfolioHandle {
        switch (coinsValueResult, assetsValueResult) {
        case (.success(let coinsValue), .success(let assetsValue)):
            let totalValue = coinsValue + assetsValue
            return totalValue.unwrap { .success($0) } ?? .failure(.currencyFailed)
        case (.success, .failure(let error)):
            return .failure(error)
        case (.failure(let error), _):
            return .failure(error)
        }
    }
}

typealias PortfolioHandle = Swift.Result<PortfolioValue, PortfolioValueError>

struct PortfolioValue {
    var primaryFormattedAmount: String {
        if currency is AlgoCurrency {
            return primaryAmount.toCurrencyStringForLabel(with: currency.symbol) ?? "N/A"
        }

        return secondaryAmount.toCurrencyStringForLabel(with: currency.symbol) ?? "N/A"
    }

    var secondaryFormattedAmount: String {
        if let algoCurrency = currency as? AlgoCurrency {
            return secondaryAmount.toCurrencyStringForLabel(with: algoCurrency.currency.symbol) ?? "N/A"
        }

        let algoCurrency = AlgoCurrency(currency: currency)
        return primaryAmount.toCurrencyStringForLabel(with: algoCurrency.symbol) ?? "N/A"
    }
    
    var primaryAbbreviatedFormattedAmount: String {
        if currency is AlgoCurrency {
            return primaryAmount.abbreviatedCurrencyStringForLabel(with: currency.symbol) ?? "N/A"
        }

        return secondaryAmount.abbreviatedCurrencyStringForLabel(with: currency.symbol) ?? "N/A"
    }

    var secondaryAbbreviatedFormattedAmount: String {
        if let algoCurrency = currency as? AlgoCurrency {
            return secondaryAmount.abbreviatedCurrencyStringForLabel(with: algoCurrency.currency.symbol) ?? "N/A"
        }

        let algoCurrency = AlgoCurrency(currency: currency)
        return primaryAmount.abbreviatedCurrencyStringForLabel(with: algoCurrency.symbol) ?? "N/A"
    }

    let primaryAmount: Decimal
    let secondaryAmount: Decimal
    let currency: Currency
}

extension PortfolioValue {
    static func + (
        lhs: PortfolioValue,
        rhs: PortfolioValue
    ) -> PortfolioValue? {
        if lhs.currency.id != rhs.currency.id {
            return nil
        }
        
        let totalPrimaryAmount = lhs.primaryAmount + rhs.primaryAmount
        let totalSecondaryAmount = lhs.secondaryAmount + rhs.secondaryAmount
        return PortfolioValue(
            primaryAmount: totalPrimaryAmount,
            secondaryAmount: totalSecondaryAmount,
            currency: lhs.currency
        )
    }
}

enum PortfolioValueError: Error {
    case idle
    case currencyFailed
    case accountsFailed
}

extension Result where Success == PortfolioValue {
    var primaryUIDescription: String {
        switch self {
        case .success(let value): return value.primaryFormattedAmount
        case .failure: return "N/A"
        }
    }

    var secondaryUIDescription: String {
        switch self {
        case .success(let value): return value.secondaryFormattedAmount
        case .failure: return "N/A"
        }
    }
    
    var primaryAbbreviatedUiDescription: String {
        switch self {
        case .success(let value): return value.primaryAbbreviatedFormattedAmount
        case .failure: return "N/A"
        }
    }

    var secondaryAbbreviatedUiDescription: String {
        switch self {
        case .success(let value): return value.secondaryAbbreviatedFormattedAmount
        case .failure: return "N/A"
        }
    }

    var primaryAmount: Decimal {
        switch self {
        case .success(let value): return value.primaryAmount
        case .failure: return .zero
        }
    }

    var secondaryAmount: Decimal {
        switch self {
        case .success(let value): return value.secondaryAmount
        case .failure: return .zero
        }
    }
}
