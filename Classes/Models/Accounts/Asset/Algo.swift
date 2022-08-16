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

//   Algo.swift

import Foundation

struct Algo: Asset {
    let id: AssetID = -1
    var amount: UInt64
    let isFrozen: Bool? = nil
    let isDeleted: Bool? = false
    let optedInAtRound: UInt64? = nil
    let creator: AssetCreator? = nil
    let decimals: Int = 6
    let decimalAmount: Decimal
    let usdValue: Decimal? = nil
    let totalUSDValue: Decimal? = nil
    var state: AssetState = .ready
    let url: String? = "www.algorand.com"
    let verificationTier: AssetVerificationTier = .trusted
    let logoURL: URL? = nil

    let naming: AssetNaming = AssetNaming(
        id: -1,
        name: "Algo",
        unitName: "ALGO"
    )
    let amountWithFraction: Decimal = 0
    let isAlgo = true

    init(
        amount: UInt64
    ) {
        self.amount = amount
        /// <note>
        /// decimalAmount = amount * 10^-(decimals)
        self.decimalAmount = Decimal(sign: .plus, exponent: -decimals, significand: Decimal(amount))
    }
}
