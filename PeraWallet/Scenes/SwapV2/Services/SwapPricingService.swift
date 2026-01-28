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

//   SwapPricingService.swift

import Foundation
import pera_wallet_core

final class SwapPricingService {
    
    private let amountFormatter: SwapAmountFormatter
    
    init(amountFormatter: SwapAmountFormatter = SwapAmountFormatter()) {
        self.amountFormatter = amountFormatter
    }
    
    func price(for quote: SwapQuote?) -> String {
        guard
            let price = quote?.price,
            let assetOut = quote?.assetOut?.unitName,
            let assetIn = quote?.assetIn?.unitName
        else {
            return "-"
        }
        
        let priceText = "\(NSDecimalNumber(decimal: price).stringValue) \(assetOut)"
        return String(format: String(localized: "swap-confirm-price-info"), priceText, assetIn)
    }
    
    func minimumReceived(for quote: SwapQuote?) -> String {
        guard
            let amountOutWithSlippage = quote?.amountOutWithSlippage,
            let assetOutUnitName = quote?.assetOut?.unitName,
            let decimals = quote?.assetOut?.decimals
        else {
            return "-"
        }
        
        let value = Decimal(amountOutWithSlippage) / pow(10, decimals)
        return "\(value) \(assetOutUnitName)"
    }
    
    func slippageTolerance(for quote: SwapQuote?) -> String {
        guard
            let slippageTolerance = quote?.slippage,
            slippageTolerance > 0
        else {
            return amountFormatter.percentage(from: 0)
        }
        return amountFormatter.percentage(from: slippageTolerance)
    }
    
    func priceImpact(for quote: SwapQuote?) -> String {
        guard
            let priceImpact = quote?.priceImpact,
            priceImpact > 0
        else {
            return amountFormatter.percentage(from: 0)
        }
        return amountFormatter.percentage(from: priceImpact)
    }
    
    func providerRate(for quote: SwapQuote?) -> String {
        guard
            let price = quote?.price,
            let assetOut = quote?.assetOut?.unitName,
            let assetIn = quote?.assetIn?.unitName
        else {
            return "-"
        }
        
        guard let rate = amountFormatter.string(from: price, maxFractionDigits: 3) else { return "-" }
        return "1 \(assetIn) ≈ \(rate) \(assetOut)"
    }
    

    
    func peraFee(for quote: SwapQuote?) -> String {
        guard
            let peraFee = quote?.peraFee,
            let decimals = quote?.assetOut?.decimals
        else {
            return "-"
        }
        
        let value = Decimal(peraFee) / pow(10, decimals)
        
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.formattingContext = .listItem
        currencyFormatter.currency = AlgoLocalCurrency()
        
        return currencyFormatter.format(value) ?? "-"
    }
    
    func exchangeFee(for quote: SwapQuote?) -> String {
        guard
            let exchangeFee = quote?.exchangeFee,
            let decimals = quote?.assetOut?.decimals
        else {
            return "-"
        }
        
        let value = Decimal(exchangeFee) / pow(10, decimals)
        
        let currencyFormatter = CurrencyFormatter()
        currencyFormatter.formattingContext = .listItem
        currencyFormatter.currency = AlgoLocalCurrency()
        
        return currencyFormatter.format(value) ?? "-"
    }
}
