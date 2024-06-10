// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsaRequestHeaderViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage

struct IncomingASARequestHeaderViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var subTitle: TextProvider?

    init(_ draft: IncomingASAListItem) {
        bindTitle(draft)
        bindSubtitle(draft)
    }
}

extension IncomingASARequestHeaderViewModel {
    
    private mutating func bindTitle(_ draft: IncomingASAListItem) {
        let amount = draft.asset.total ?? 0
        
        
        var currencyFormatter = CurrencyFormatter()

        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()

        let amountText = currencyFormatter.format(amount.toAlgos)

        title = amountText.someString
            .titleMedium(alignment: .center)
    }

    private mutating func bindSubtitle(_ draft: IncomingASAListItem) {
//        let value = draft.asset.usdValue
//        
//        
//        var currencyFormatter = CurrencyFormatter()
//
//        currencyFormatter.formattingContext = .standalone()
//        currencyFormatter.currency = AlgoLocalCurrency()
//
//        let amountText = currencyFormatter.format(usdValue.toAlgos)
//        
//        CurrencyProvider()
//        guard let amountUSDValue = value,
//              let fiatCurrencyValue = currency.fiatValue else {
//            return getDetailValue(text: "0.00", priceImpact: priceImpact)
//        }
        
        
        let aTitle =
        (draft.accountAddress?.decimalAmount ?? 0).stringValue
            .bodyRegular(alignment: .center)
        subTitle = aTitle
    }
    
    func getDetailValue(
        text: String?,
        priceImpact: Decimal?
    ) -> TextProvider?  {
        let attributes: TextAttributeGroup

        if let priceImpact,
           priceImpact > PriceImpactLimit.fivePercent {
            var someAttributes = Typography.footnoteRegularAttributes()
            someAttributes.insert(.textColor(Colors.Helpers.negative))
            attributes = someAttributes
        } else {
            var someAttributes = Typography.footnoteRegularAttributes()
            someAttributes.insert(.textColor(Colors.Text.grayLighter))
            attributes = someAttributes
        }

        if let text = text.unwrapNonEmptyString() {
            return text.attributed(attributes)
        } else {
            return nil
        }
    }

}
