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

//   Algo.swift

import Foundation

public final class Algo: Asset {
    public let id: AssetID = 0
    public var amount: UInt64
    public let isFrozen: Bool? = nil
    public let isDestroyed: Bool = false
    public let optedInAtRound: UInt64? = nil
    public let creator: AssetCreator? = nil
    public let decimals: Int = 6
    public let decimalAmount: Decimal
    public let total: UInt64?
    public let totalSupply: Decimal?
    public let usdValue: Decimal? = nil
    public let totalUSDValue: Decimal? = nil
    public var state: AssetState = .ready
    public let url: String? = AlgorandWeb.algorand.rawValue
    public let verificationTier: AssetVerificationTier = .trusted
    public let projectURL: URL?
    public let explorerURL: URL? = nil
    public let logoURL: URL? = nil
    public let description: String?
    public let discordURL: URL?
    public let telegramURL: URL?
    public let twitterURL: URL?
    public let algoPriceChangePercentage: Decimal = 0
    public let isAvailableOnDiscover: Bool = true

    public let naming: AssetNaming = AssetNaming(
        id: 0,
        name: "Algo",
        unitName: "ALGO"
    )
    public let amountWithFraction: Decimal = 0
    public let isAlgo = true
    public func isUSDC(for network: ALGAPI.Network) -> Bool { false }
    public let isFault = false

    init(
        amount: UInt64
    ) {
        self.amount = amount
        /// <note>
        /// decimalAmount = amount * 10^-(decimals)
        self.decimalAmount = Decimal(sign: .plus, exponent: -decimals, significand: Decimal(amount))

        /// microTotalSupply
        let total: UInt64 = 10_000_000_000_000_000
        self.total = total
        /// totalSupply = total * 10^-(decimals)
        self.totalSupply = Decimal(sign: .plus, exponent: -decimals, significand: Decimal(total))
        self.description = String(localized: "asset-algos-description")
        self.projectURL = AlgorandWeb.algorand.link
        self.discordURL = URL(string: "https://discord.com/invite/algorand")
        self.telegramURL = URL(string: "https://t.me/algorand")
        self.twitterURL = URL.twitterURL(username: "Algorand")
    }
}
