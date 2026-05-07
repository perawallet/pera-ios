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

//   AssetStatisticsSectionPriceViewModel.swift

import MacaroonUIKit
import pera_wallet_core

struct AssetStatisticsSectionPriceViewModel: PrimaryTitleViewModel {
    var primaryTitle: TextProvider?
    var favoriteTitleAccessory: Image?
    var primaryTitleAccessory: Image?
    var secondaryTitle: TextProvider?

    init(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        chartPointSelected: ChartSelectedPointViewModel? = nil
    ) {
        bindTitle()
        guard let chartPointSelected else {
            bindSubtitle(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
            return
        }
        
        bindSubtitle(for: chartPointSelected)
    }
}

extension AssetStatisticsSectionPriceViewModel {
    mutating func bindTitle() {
        primaryTitle = String(localized: "title-price")
            .footnoteRegular(
                lineBreakMode: .byTruncatingTail
            )
    }
    
    mutating func bindSubtitle(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        if asset.isAlgo {
            bindAlgoSubtitle(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        } else {
            bindAssetSubtitle(
                asset: asset,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        }
    }
    
    private mutating func bindAlgoSubtitle(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let fiatCurrencyValue = currency.fiatValue,
              let fiatRawCurrency = try? fiatCurrencyValue.unwrap(),
              let usdRate = fiatRawCurrency.usdValue else
        {
            bindSubtitle(text: nil)
            return
        }
        
        do {
            let exchanger = CurrencyExchanger(currency: fiatRawCurrency)
            let amountInUSD = try exchanger.exchangeAlgoToUSD(amount: 1)
            let amount = amountInUSD * usdRate
            
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = fiatRawCurrency
            
            guard var text = currencyFormatter.format(amount) else {
                bindSubtitle(text: nil)
                return
            }
            
            if
                !fiatRawCurrency.isUSD,
                let usdText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 6).string(for: amountInUSD)
            {
                text += "\n$" + usdText
            }
            
            bindSubtitle(text: text)
        } catch {
            bindSubtitle(text: nil)
        }
    }
    
    private mutating func bindAssetSubtitle(
        asset: Asset,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let currencyValue = try? currency.primaryValue?.unwrap() else {
            bindSubtitle(text: nil)
            return
        }
        
        let exchanger = CurrencyExchanger(currency: currencyValue)
        guard let amount = try? exchanger.exchange(asset, amount: 1) else {
            bindSubtitle(text: nil)
            return
        }
        
        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = currencyValue
        guard let text = currencyFormatter.format(amount) else {
            bindSubtitle(text: nil)
            return
        }
        
        guard !currencyValue.isUSD else {
            bindSubtitle(text: text)
            return
        }
        
        var finalText = text
        
        if
            let usdRate = try? (currencyValue.isAlgo ? currency.algoValue?.unwrap().usdValue : currency.fiatValue?.unwrap().usdValue),
            usdRate != 0
        {
            let amountInUSD = amount / usdRate
            if let usdText = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 6).string(for: amountInUSD) {
                finalText += "\n$" + usdText
            }
        }
        
        bindSubtitle(text: finalText)
    }
    
    private mutating func bindSubtitle(for chartPointSelected: ChartSelectedPointViewModel) {
        if let usdText = Formatter.decimalFormatter(
            minimumFractionDigits: 0,
            maximumFractionDigits: 6
        ).string(for: chartPointSelected.fiatValue) {
            bindSubtitle(text: "$" + usdText)
        } else {
            bindSubtitle(text: nil)
        }
    }
    
    mutating func bindSubtitle(text: String?) {
        secondaryTitle = (text ?? "-").bodyLargeMedium(lineBreakMode: .byTruncatingTail)
    }
}
