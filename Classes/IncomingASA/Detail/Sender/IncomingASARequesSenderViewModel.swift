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

//   IncomingAsaSenderViewModel.swift

import Foundation
import MacaroonUIKit

struct IncomingASARequesSenderViewModel: ViewModel {
    private(set) var amount: TextProvider?
    private(set) var sender: TextProvider?

    init(
        currencyFormatter: CurrencyFormatter,
        asset: Asset,
        amount: UInt64?,
        sender: Sender?
    ) {
        bindAmount(
            currencyFormatter: currencyFormatter,
            asset: asset,
            amountValue: amount
        )
        bindSender(sender)
    }
}

extension IncomingASARequesSenderViewModel {
    mutating func bindAmount(
        currencyFormatter: CurrencyFormatter,
        asset: Asset?,
        amountValue: UInt64?
    ) {
        guard let asset,
              let amountValue else {
            return
        }
        
        let decimalAmount = amountValue.assetAmount(fromFraction: asset.decimals)
        let amountText = currencyFormatter.format(decimalAmount)
        let unitText =
            asset.naming.unitName.unwrapNonEmptyString() ?? asset.naming.name.unwrapNonEmptyString()
        let text = [amountText, unitText].compound(" ")
        amount = "+\(text)"
    }
    
    mutating func bindSender(_ senderValue: Sender?) {
        guard let senderValue else { return }
        
        let aSender = senderValue.name ?? senderValue.address
        sender = aSender?.footnoteRegular()
    }
}
