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

//   SelectAddressListItemViewModel.swift

import Foundation
import MacaroonUIKit

struct SelectAddressListItemViewModel:
    ViewModel,
    Hashable {
    private(set) var title: TextProvider?
    private(set) var mainCurrency: TextProvider?
    private(set) var secondaryCurrency: TextProvider?

    init(
        _ recoveredAddress: RecoveredAddress,
        currencyFormatter: CurrencyFormatter,
        currencyProvider: CurrencyProvider
    ) {
        bindTitle(recoveredAddress)
        bindMainCurrency(
            recoveredAddress,
            currencyFormatter: currencyFormatter,
            currencyProvider: currencyProvider
        )
        bindSecondaryCurrency(
            recoveredAddress,
            currencyFormatter: currencyFormatter,
            currencyProvider: currencyProvider
        )
    }
}

extension SelectAddressListItemViewModel {
    private mutating func bindTitle(
        _ recoveredAddress: RecoveredAddress
    ) {
        self.title = recoveredAddress.address.shortAddressDisplay
        
    }
    
    private mutating func bindMainCurrency(
        _ recoveredAddress: RecoveredAddress,
        currencyFormatter: CurrencyFormatter,
        currencyProvider: CurrencyProvider
    ) {
        
        if let currency = try? currencyProvider.primaryValue?.unwrap() {
            currencyFormatter.currency = currency
        } else {
            currencyFormatter.currency = AlgoLocalCurrency()
        }
        
        currencyFormatter.formattingContext = .listItem
        self.mainCurrency = currencyFormatter.format(recoveredAddress.mainCurrency)
    }
    
    private mutating func bindSecondaryCurrency(
        _ recoveredAddress: RecoveredAddress,
        currencyFormatter: CurrencyFormatter,
        currencyProvider: CurrencyProvider
    ) {
        guard let currency = try? currencyProvider.secondaryValue?.unwrap() else {
            self.secondaryCurrency = nil
            return
        }
        currencyFormatter.currency = currency
        currencyFormatter.formattingContext = .listItem
        self.secondaryCurrency = currencyFormatter.format(recoveredAddress.secondaryCurrency)
    }
}

extension SelectAddressListItemViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title?.string)
        hasher.combine(mainCurrency?.string)
        hasher.combine(secondaryCurrency?.string)
    }

    static func == (
        lhs: SelectAddressListItemViewModel,
        rhs: SelectAddressListItemViewModel
    ) -> Bool {
        return lhs.title?.string == rhs.title?.string
        && lhs.mainCurrency?.string == rhs.mainCurrency?.string
        && lhs.secondaryCurrency?.string == rhs.secondaryCurrency?.string
    }
}
