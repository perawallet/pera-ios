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

//   SwapStatusEventMapper.swift

import Foundation
import SwiftDate

struct SwapStatusEventMapper {
    private lazy var swapAssetValueFormatter = SwapAssetValueFormatter()
    private lazy var currencyFormatter = CurrencyFormatter()

    private let quote: SwapQuote
    private let currency: CurrencyProvider

    init(
        quote: SwapQuote,
        currency: CurrencyProvider
    ) {
        self.quote = quote
        self.currency = currency
    }

    mutating func mapEventParams() -> SwapStatusEventParams? {
        guard let assetIn = quote.assetIn,
              let assetOut = quote.assetOut,
              let amountIn = quote.amountIn,
              let amountOut = quote.amountOut else {
            return nil
        }

        let decimalAmountIn = swapAssetValueFormatter.getDecimalAmount(of: amountIn, for: assetIn)
        let amountInValue = swapAssetValueFormatter.getFormattedAssetAmount(
            decimalAmount: decimalAmountIn,
            currencyFormatter: currencyFormatter,
            maximumFractionDigits: assetIn.decimals
        )
        let amountInUSDValue = swapAssetValueFormatter.getFormattedAssetAmount(
            decimalAmount: (quote.amountInUSDValue ?? 0),
            currencyFormatter: currencyFormatter,
            maximumFractionDigits: assetIn.decimals
        )
        let amountInAlgoValue = ""

        let decimalAmountOut = swapAssetValueFormatter.getDecimalAmount(of: amountOut, for: assetOut)
        let amountOutValue = swapAssetValueFormatter.getFormattedAssetAmount(
            decimalAmount: decimalAmountOut,
            currencyFormatter: currencyFormatter,
            maximumFractionDigits: assetOut.decimals
        )
        let amountOutUSDValue = swapAssetValueFormatter.getFormattedAssetAmount(
            decimalAmount: (quote.amountOutUSDValue ?? 0),
            currencyFormatter: currencyFormatter,
            maximumFractionDigits: assetIn.decimals
        )
        let amountOutAlgoValue = ""

        var peraFeeAsUSD = ""
        var peraFeeAsAlgo = ""
        if let peraFee = quote.peraFee {
            let decimalPeraFee = Decimal(
                sign: .plus,
                exponent: -6,
                significand: Decimal(peraFee)
            )
            peraFeeAsAlgo = swapAssetValueFormatter.getFormattedAssetAmount(
                decimalAmount: decimalPeraFee,
                currencyFormatter: currencyFormatter,
                maximumFractionDigits: 6
            ) ?? ""
        }

        var exchangeFeeAsAlgo = ""
        if let exchangeFee = quote.exchangeFee {
            let decimalExchangeFee = swapAssetValueFormatter.getDecimalAmount(of: exchangeFee, for: assetIn)

        }

        var networkFeeAsAlgo = ""

        let inputASAID = "\(assetIn.id)"
        let inputASAName = swapAssetValueFormatter.getAssetDisplayName(assetIn)
        let inputASAAmount = amountInValue ?? ""
        let inputUSDAmount = amountInUSDValue ?? ""
        let inputAlgoAmount = amountInAlgoValue
        let outputASAID = "\(assetOut.id)"
        let outputASAName = swapAssetValueFormatter.getAssetDisplayName(assetOut)
        let outputASAAmount = amountOutValue ?? ""
        let outputUSDAmount = amountOutUSDValue ?? ""
        let outputAlgoAmount = amountOutAlgoValue
        let swapDate = Date().toFormat("MMMM dd, yyyy - HH:mm")
        let swapDateTimestamp = Date().timeIntervalSince1970
        let swapperAddress = quote.swapperAddress ?? ""

        return SwapStatusEventParams(
            inputASAID: inputASAID,
            inputASAName: inputASAName,
            inputAmountAsASA: inputASAAmount,
            inputAmountAsUSD: inputUSDAmount,
            inputAmountAsAlgo: inputAlgoAmount,
            outputASAID: outputASAID,
            outputASAName: outputASAName,
            outputAmountAsASA: outputASAAmount,
            outputAmountAsUSD: outputUSDAmount,
            outputAmountAsAlgo: outputAlgoAmount,
            swapDate: swapDate,
            swapDateTimestamp: swapDateTimestamp,
            peraFeeAsUSD: peraFeeAsUSD,
            peraFeeAsAlgo: peraFeeAsAlgo,
            exchangeFeeAsAlgo: exchangeFeeAsAlgo,
            networkFeeAsAlgo: networkFeeAsAlgo,
            swapperAddress: swapperAddress
        )
    }
}

extension SwapStatusEventMapper {
    struct SwapStatusEventParams {
        let inputASAID: String
        let inputASAName: String
        let inputAmountAsASA: String
        let inputAmountAsUSD: String
        let inputAmountAsAlgo: String
        let outputASAID: String
        let outputASAName: String
        let outputAmountAsASA: String
        let outputAmountAsUSD: String
        let outputAmountAsAlgo: String
        let swapDate: String
        let swapDateTimestamp: Double
        let peraFeeAsUSD: String
        let peraFeeAsAlgo: String
        let exchangeFeeAsAlgo: String
        let networkFeeAsAlgo: String
        let swapperAddress: String
    }
}
