// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapCurrencyService.swift

import Foundation
import pera_wallet_core

final class SwapCurrencyService {
    
    private let currency: CurrencyProvider
    private let amountFormatter: SwapAmountFormatter
    
    private var fiatCurrency: RemoteCurrency? { try? currency.fiatValue?.unwrap() }
    private var algoCurrency: RemoteCurrency? { try? currency.algoValue?.unwrap() }
    
    init(currency: CurrencyProvider, amountFormatter: SwapAmountFormatter = SwapAmountFormatter()) {
        self.currency = currency
        self.amountFormatter = amountFormatter
    }
    
    // MARK: - Algo <> Fiat
    
    private func fiatValue(fromAlgo amount: Double) -> Double {
        guard let currencyFiatValue = fiatCurrency else { return 0 }
        let exchanger = CurrencyExchanger(currency: currencyFiatValue)
        
        guard let fiatAmount = try? exchanger.exchangeAlgo(amount: Decimal(amount)) else {
            return 0
        }
        
        return fiatAmount.doubleValue
    }
    
    func algoValue(fromFiat amount: Double) -> Double {
        guard let currencyFiatValue = fiatCurrency else { return 0 }
        let exchanger = CurrencyExchanger(currency: currencyFiatValue)
        
        guard let algoAmount = try? exchanger.exchangeFiat(amount: Decimal(amount)) else {
            return 0
        }
        return algoAmount.doubleValue
    }
    
    // MARK: - Asset <> Fiat
    
    private func fiatValue(fromUSDC amount: Double) -> Double {
        guard let currencyFiatValue = fiatCurrency else { return 0 }
        let exchanger = CurrencyExchanger(currency: currencyFiatValue)
        
        guard let fiatAmount = try? exchanger.exchange(amount: Decimal(amount)) else {
            return 0
        }
        
        return fiatAmount.doubleValue
    }
    
    private func fiatValue(fromAsset asset: Asset, with amount: Double) -> Double {
        guard let currencyFiatValue = fiatCurrency else { return 0 }
        guard
            let fiatAmount = try? {
                let exchanger = CurrencyExchanger(currency: currencyFiatValue)
                return asset.isAlgo
                ? try exchanger.exchangeAlgo(amount: Decimal(amount))
                : try exchanger.exchange(asset, amount: Decimal(amount))
            }()
        else {
            return 0
        }
        return fiatAmount.doubleValue
    }
    
    // MARK: - Formatting helpers
    
    func fiatValueText(fromAlgo amount: Double) -> String {
        fiatFormat(with: fiatValue(fromAlgo: amount))
    }
    
    func fiatFormat(with amount: Double) -> String {
        guard let currencyFiatValue = fiatCurrency else { return .empty }
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.currency = currencyFiatValue
        return currencyFormatter.format(amount) ?? .empty
    }
    
    func fiatValueText(fromUSDC amount: Double) -> String {
        fiatFormat(with: fiatValue(fromUSDC: amount))
    }
    
    func fiatValueText(fromAsset asset: Asset, with amount: Double) -> String {
        fiatFormat(with: fiatValue(fromAsset: asset, with: amount))
    }
    
    private func algoValueText(fromFiat amount: Double) -> String {
        algoFormat(with: algoValue(fromFiat: amount))
    }
    
    private func algoFormat(with amount: Double) -> String {
        guard let currencyAlgoValue = algoCurrency else { return .empty }
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.currency = currencyAlgoValue
        return currencyFormatter.format(amount) ?? .empty
    }
}
