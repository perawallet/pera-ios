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

//   BidaliBalances.swift

import Foundation

struct BidaliBalances:
    Encodable,
    Equatable {
    private let algo: Decimal?
    private let usdc: Decimal?
    private let usdt: Decimal?
    private let testnetUSDC: Decimal?

    init(
        account: AccountHandle,
        network: ALGAPI.Network
    ) {
        self.algo = account.value.algo.decimalAmount
        self.usdc = account.value[BidaliPaymentCurrency.usdcAssetID]?.decimalAmount
        self.usdt = account.value[BidaliPaymentCurrency.usdtAssetID]?.decimalAmount
        self.testnetUSDC = network == .testnet ? account.value[BidaliPaymentCurrency.testnetUSDCAssetID]?.decimalAmount : nil
    }
}

extension BidaliBalances {
    enum CodingKeys:
        String,
        CodingKey {
        case algo = "algorand"
        case usdc = "usdcalgorand"
        case usdt = "usdtalgorand"
        case testnetUSDC = "testusdcalgorand"
    }

    func encode(to encoder: Encoder) throws {
        let transformedAlgo = transformValueForEncoding(algo)
        let transformedUSDC = transformValueForEncoding(usdc)
        let transformedUSDT = transformValueForEncoding(usdt)
        let transformedtestnetUSDC = transformValueForEncoding(testnetUSDC)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(transformedAlgo, forKey: .algo)
        try container.encodeIfPresent(transformedUSDC, forKey: .usdc)
        try container.encodeIfPresent(transformedUSDT, forKey: .usdt)
        try container.encodeIfPresent(transformedtestnetUSDC, forKey: .testnetUSDC)
    }

    private func transformValueForEncoding(_ value: Decimal?) -> String? {
        guard let value else {
            return nil
        }

        return NSDecimalNumber(decimal: value).stringValue
    }
}

extension BidaliBalances {
    func toJSONString() -> Result<String, BalancesEncodingError> {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return .failure(.failedToEncode)
        }

        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return .failure(.failedToConvertToJSON)
        }

        return .success(jsonString)
    }
}

enum BalancesEncodingError: Error {
    case failedToEncode
    case failedToConvertToJSON
}
