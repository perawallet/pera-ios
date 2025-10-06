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

//   StandardAsset.swift

import Foundation

public final class StandardAsset: Asset {
    public let id: AssetID
    public let amount: UInt64
    public let decimals: Int
    public let decimalAmount: Decimal
    public let total: UInt64?
    public let totalSupply: Decimal?
    public let isFrozen: Bool?
    public let isDestroyed: Bool
    public let optedInAtRound: UInt64?
    public let name: String?
    public let unitName: String?
    public let usdValue: Decimal?
    public let totalUSDValue: Decimal?
    public let verificationTier: AssetVerificationTier
    public let creator: AssetCreator?
    public let url: String?
    public let projectURL: URL?
    public let explorerURL: URL?
    public let logoURL: URL?
    public let description: String?
    public let discordURL: URL?
    public let telegramURL: URL?
    public let twitterURL: URL?
    public let isAlgo = false
    public let algoPriceChangePercentage: Decimal
    public let isAvailableOnDiscover: Bool
    public let category: UInt64?

    public let isFault: Bool
    
    public var state: AssetState = .ready

    public var naming: AssetNaming {
        return AssetNaming(
            id: id,
            name: name,
            unitName: unitName
        )
    }

    public var amountWithFraction: Decimal {
        return amount.assetAmount(fromFraction: decimals)
    }

    public init(
        asset: ALGAsset,
        decoration: AssetDecoration
    ) {
        self.id = asset.id
        self.isFrozen = asset.isFrozen
        self.isDestroyed = decoration.isDestroyed
        self.optedInAtRound = asset.optedInAtRound
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.verificationTier = decoration.verificationTier
        self.creator = decoration.creator
        self.url = decoration.url
        self.projectURL = decoration.projectURL
        self.explorerURL = decoration.explorerURL
        self.logoURL = decoration.logoURL
        self.total = decoration.total
        self.totalSupply = decoration.totalSupply
        self.category = asset.category

        let amount = asset.amount
        let decimals = decoration.decimals
        /// <note>
        /// decimalAmount = amount * 10^-(decimals)
        let decimalAmount = Decimal(sign: .plus, exponent: -decimals, significand: Decimal(amount))
        let usdValue = decoration.usdValue

        self.amount = amount
        self.decimals = decimals
        self.decimalAmount = decimalAmount
        self.usdValue = usdValue
        self.totalUSDValue = usdValue.unwrap { $0 * decimalAmount }
        self.description = decoration.description
        self.discordURL = decoration.discordURL
        self.telegramURL = decoration.telegramURL
        self.twitterURL = decoration.twitterURL
        self.isFault = false
        self.algoPriceChangePercentage = decoration.algoPriceChangePercentage
        self.isAvailableOnDiscover = decoration.isAvailableOnDiscover
    }

    public init(
        decoration: AssetDecoration
    ) {
        self.id = decoration.id
        self.isFrozen = nil
        self.isDestroyed = decoration.isDestroyed
        self.optedInAtRound = nil
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.verificationTier = decoration.verificationTier
        self.creator = decoration.creator
        self.url = decoration.url
        self.projectURL = decoration.projectURL
        self.explorerURL = decoration.explorerURL
        self.logoURL = decoration.logoURL
        self.total = decoration.total
        self.totalSupply = decoration.totalSupply
        self.amount = 0
        self.decimals = decoration.decimals
        self.decimalAmount = 0
        self.usdValue = decoration.usdValue
        self.totalUSDValue = nil
        self.description = decoration.description
        self.discordURL = decoration.discordURL
        self.telegramURL = decoration.telegramURL
        self.twitterURL = decoration.twitterURL
        self.isFault = true
        self.algoPriceChangePercentage = decoration.algoPriceChangePercentage
        self.isAvailableOnDiscover = decoration.isAvailableOnDiscover
        self.category = nil
    }
    
    public init(
        swapAsset: SwapAsset
    ) {
        self.id = swapAsset.assetID
        self.isFrozen = nil
        self.isDestroyed = false
        self.optedInAtRound = nil
        self.name = swapAsset.name
        self.unitName = swapAsset.unitName
        self.verificationTier = AssetVerificationTier(rawValue: swapAsset.verificationTier) ?? .unverified
        self.creator = nil
        self.url = nil
        self.projectURL = nil
        self.explorerURL = nil
        self.logoURL = URL(string: swapAsset.logo ?? .empty)
        self.total = UInt64(swapAsset.total)
        self.totalSupply = nil
        self.amount = 0
        self.decimals = swapAsset.fractionDecimals
        self.decimalAmount = 0
        self.usdValue = Decimal(string: swapAsset.usdValue ?? .empty)
        self.totalUSDValue = nil
        self.description = nil
        self.discordURL = nil
        self.telegramURL = nil
        self.twitterURL = nil
        self.isFault = swapAsset.isFault
        self.algoPriceChangePercentage = 0
        self.isAvailableOnDiscover = false
        self.category = nil
    }
}

extension StandardAsset {
    public var assetNameRepresentation: String {
        if let name = name,
           !name.isEmptyOrBlank {
            return name
        }

        return String(localized: "title-unknown")
    }

    public var unitNameRepresentation: String {
        if let code = unitName,
            !code.isEmptyOrBlank {
            return code.uppercased()
        }

        return String(localized: "title-unknown")
    }

    public var hasDisplayName: Bool {
        return !name.isNilOrEmpty || !unitName.isNilOrEmpty
    }
    
    public func isUSDC(for network: ALGAPI.Network) -> Bool {
        id == ALGAsset.usdcAssetID(network)
    }
}

extension StandardAsset: Comparable {
    public static func == (lhs: StandardAsset, rhs: StandardAsset) -> Bool {
        return lhs.id == rhs.id &&
            lhs.amount == rhs.amount &&
            lhs.isFrozen == rhs.isFrozen &&
            lhs.isDestroyed == rhs.isDestroyed &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName &&
            lhs.decimals == rhs.decimals &&
            lhs.usdValue == rhs.usdValue &&
            lhs.verificationTier == rhs.verificationTier &&
            lhs.optedInAtRound == rhs.optedInAtRound
    }

    public static func < (lhs: StandardAsset, rhs: StandardAsset) -> Bool {
        return lhs.id < rhs.id
    }
}

extension StandardAsset: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
