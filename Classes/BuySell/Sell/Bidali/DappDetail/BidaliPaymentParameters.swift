// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BidaliPaymentParameters.swift

import Foundation
import MacaroonUtils

struct BidaliPaymentParameters: JSONModel {
    let data: BidaliPaymentRequest?
}

struct BidaliPaymentRequest: JSONModel {
    /// The address to send to.
    let address: String?
    /// The amount to send.
    let amount: String?
    /// The protocol of the currency the user has chosen to pay with, this is unique for each currency.
    let currencyProtocol: BidaliPaymentCurrencyProtocol?
    /// The extraId that must be passed as a note for the payment to be credited appropriately to the order.
    let extraID: String?

    enum CodingKeys:
        String,
        CodingKey {
        case address
        case amount
        case currencyProtocol = "protocol"
        case extraID = "extraId"
    }
}

enum BidaliPaymentCurrencyProtocol:
    RawRepresentable,
    CaseIterable,
    Hashable,
    JSONModel {
    case algorand
    case usdcalgorand
    case usdtalgorand
    case testnetusdcalgorand
    case unknown(String)

    var rawValue: String {
        switch self {
        case .algorand: return "algorand"
        case .usdcalgorand: return "usdcalgorand"
        case .usdtalgorand: return "usdtalgorand"
        case .testnetusdcalgorand: return "testusdcalgorand"
        case .unknown(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .algorand, .usdcalgorand, .usdtalgorand, .testnetusdcalgorand
    ]

    init?(
        rawValue: String
    ) {
        let foundCase = Self.allCases.first { $0.rawValue == rawValue }
        self = foundCase ?? .unknown(rawValue)
    }

    static func supportedProtocols(for network: ALGAPI.Network) -> [String] {
        switch network {
        case .testnet:
            return [
                BidaliPaymentCurrencyProtocol.algorand.rawValue,
                BidaliPaymentCurrencyProtocol.testnetusdcalgorand.rawValue
            ]
        case .mainnet:
            return [
                BidaliPaymentCurrencyProtocol.algorand.rawValue,
                BidaliPaymentCurrencyProtocol.usdcalgorand.rawValue,
                BidaliPaymentCurrencyProtocol.usdtalgorand.rawValue
            ]
        }
    }
}
