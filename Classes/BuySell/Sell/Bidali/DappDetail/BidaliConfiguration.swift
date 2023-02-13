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

//   BidaliConfiguration.swift

import Foundation

struct BidaliConfiguration {
    private let account: AccountHandle
    private let network: ALGAPI.Network

    lazy var key: String = {
        /// <todo> Move to config file?
        switch network {
        case .testnet: return "pk_6ppze8rn448cr1xc5rj0ki"
        case .mainnet: return "pk_obszzygjjzbp9oqewl44rq"
        }
    }()

    /// The name of the wallet integrating (Provided by Bidali).
    lazy var name: String = "perawallet"

    lazy var url: String = {
        switch network {
        case .testnet: return "https://commerce.staging.bidali.com/dapp?key=\(key)"
        case .mainnet: return "https://commerce.bidali.com/dapp?key=\(key)"
        }
    }()

    /// Allows you to only show certain cryptocurrencies as payment options.
    lazy var paymentCurrencies: [String] = {
        switch network {
        case .testnet: return BidaliPaymentCurrency.testnetValues
        case .mainnet: return BidaliPaymentCurrency.mainnetValues
        }
    }()

    /// The balances for the allowed currencies.
    lazy var balances: Result<String, BalancesEncodingError> = {
        let balances = BidaliBalances(account: account, network: network)
        return balances.toJSONString()
    }()

    init(
        account: AccountHandle,
        network: ALGAPI.Network
    ) {
        self.account = account
        self.network = network
    }
}

enum BidaliPaymentCurrency:
    String,
    Decodable {
    static let usdcAssetID: AssetID = 31566704
    static let usdtAssetID: AssetID = 312769
    static let testnetUSDCAssetID: AssetID = 10458941

    case algorand = "algorand"
    case usdcalgorand = "usdcalgorand"
    case usdtalgorand = "usdtalgorand"
    case testnetusdcalgorand = "testusdcalgorand"

    static let testnetValues: [String] = [
        BidaliPaymentCurrency.algorand.rawValue,
        BidaliPaymentCurrency.testnetusdcalgorand.rawValue
    ]
    static let mainnetValues: [String] = [
        BidaliPaymentCurrency.algorand.rawValue,
        BidaliPaymentCurrency.usdcalgorand.rawValue,
        BidaliPaymentCurrency.usdtalgorand.rawValue
    ]
}
