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

//   CurrencyProvider.swift

import Foundation
import SwiftDate

protocol CurrencyProvider: AnyObject {
    typealias EventHandler = (CurrencyEvent) -> Void

    var primaryValue: CurrencyValue? { get }
    var secondaryValue: CurrencyValue? { get }

    var isExpired: Bool { get }

    func refresh(
        on queue: DispatchQueue
    )

    func setAsPrimaryCurrency(
        _ currencyID: CurrencyID
    )

    func addObserver(
        using handler: @escaping EventHandler
    ) -> UUID
    func removeObserver(
        _ observer: UUID
    )
}

extension CurrencyProvider {
    var algoRawCurrency: Currency? {
        get throws {
            guard
                let primaryValue = primaryValue,
                let secondaryValue = secondaryValue
            else {
                return nil
            }

            let primaryRawCurrency = try primaryValue.unwrap()
            let secondaryRawCurrency = try secondaryValue.unwrap()

            if primaryRawCurrency.isAlgo {
                return primaryRawCurrency
            }

            if secondaryRawCurrency.isAlgo {
                return secondaryRawCurrency
            }

            return nil
        }
    }

    var fiatRawCurrency: Currency? {
        get throws {
            guard
                let primaryValue = primaryValue,
                let secondaryValue = secondaryValue
            else {
                return nil
            }

            let primaryRawCurrency = try primaryValue.unwrap()
            let secondaryRawCurrency = try secondaryValue.unwrap()

            if !primaryRawCurrency.isAlgo {
                return primaryRawCurrency
            }

            if !secondaryRawCurrency.isAlgo {
                return secondaryRawCurrency
            }

            return nil
        }
    }
}

extension CurrencyProvider {
    func calculateExpirationDate(
        starting startDate: Date
    ) -> Date {
        return startDate + 1.minutes
    }
}

enum CurrencyEvent {
    case didUpdate
}
