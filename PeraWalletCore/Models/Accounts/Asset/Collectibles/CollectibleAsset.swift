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

//   CollectibleAsset.swift

import Foundation

public final class CollectibleAsset: Asset {
    public var optedInAddress: String?
    public var state: AssetState = .ready

    public let id: AssetID
    public private(set) var amount: UInt64
    public private(set) var decimals: Int
    public private(set) var total: UInt64?
    public private(set) var totalSupply: Decimal?
    public private(set) var decimalAmount: Decimal
    public private(set) var isFrozen: Bool?
    public private(set) var isDestroyed: Bool
    public private(set) var optedInAtRound: UInt64?
    public private(set) var creator: AssetCreator?
    public private(set) var category: String?
    public private(set) var name: String?
    public private(set) var unitName: String?
    public private(set) var usdValue: Decimal?
    public private(set) var totalUSDValue: Decimal?
    public private(set) var verificationTier: AssetVerificationTier
    public private(set) var thumbnailImage: URL?
    public private(set) var media: [Media]
    public private(set) var standard: CollectibleStandard?
    public private(set) var mediaType: MediaType
    public private(set) var title: String?
    public private(set) var collection: CollectibleCollection?
    public private(set) var url: String?
    public private(set) var description: String?
    public private(set) var properties: [CollectibleTrait]?
    public private(set) var projectURL: URL?
    public private(set) var explorerURL: URL?
    public private(set) var logoURL: URL?
    public private(set) var discordURL: URL?
    public private(set) var telegramURL: URL?
    public private(set) var twitterURL: URL?
    public private(set) var algoPriceChangePercentage: Decimal
    public private(set) var isAvailableOnDiscover: Bool

    public let isAlgo = false
    public let isFault = false

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

    public var isOwned: Bool {
        return amount != 0
    }

    public var containsUnsupportedMedia: Bool {
        return media.contains { !$0.type.isSupported }
    }

    /// Collectibles that are pure (non-frictional) according to ARC3
    /// https://github.com/algorandfoundation/ARCs/blob/main/ARCs/arc-0003.md#pure-and-fractional-nfts
    public var isPure: Bool {
        guard let total = total else {
            return false
        }

        return total == 1 && decimals == 0
    }

    public init(
        asset: ALGAsset,
        decoration: AssetDecoration
    ) {
        self.id = asset.id
        self.isFrozen = asset.isFrozen
        self.isDestroyed = decoration.isDestroyed
        self.optedInAtRound = asset.optedInAtRound
        self.creator = decoration.creator
        self.category = decoration.category
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.total = decoration.total
        self.totalSupply = decoration.totalSupply
        self.verificationTier = decoration.verificationTier
        self.thumbnailImage = decoration.collectible?.thumbnailImage
        self.mediaType = decoration.collectible?.mediaType ?? .unknown("")
        self.standard = decoration.collectible?.standard ?? .unknown("")
        self.media = decoration.collectible?.media ?? []
        self.title = decoration.collectible?.title
        self.collection = decoration.collectible?.collection
        self.url = decoration.url
        self.description = decoration.collectible?.description
        self.properties = decoration.collectible?.properties
        self.projectURL = decoration.projectURL
        self.explorerURL = decoration.explorerURL
        self.logoURL = decoration.logoURL
        self.discordURL = decoration.discordURL
        self.telegramURL = decoration.telegramURL
        self.twitterURL = decoration.twitterURL

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
        self.algoPriceChangePercentage = decoration.algoPriceChangePercentage
        self.isAvailableOnDiscover = decoration.isAvailableOnDiscover
    }

    public init(decoration: AssetDecoration) {
        self.id = decoration.id
        self.isFrozen = nil
        self.isDestroyed = decoration.isDestroyed
        self.optedInAtRound = nil
        self.creator = decoration.creator
        self.name = decoration.name
        self.unitName = decoration.unitName
        self.total = decoration.total
        self.totalSupply = decoration.totalSupply
        self.verificationTier = decoration.verificationTier
        self.thumbnailImage = decoration.collectible?.thumbnailImage
        self.mediaType = decoration.collectible?.mediaType ?? .unknown("")
        self.standard = decoration.collectible?.standard ?? .unknown("")
        self.media = decoration.collectible?.media ?? []
        self.title = decoration.collectible?.title
        self.collection = decoration.collectible?.collection
        self.url = decoration.url
        self.description = decoration.collectible?.description
        self.properties = decoration.collectible?.properties
        self.projectURL = decoration.projectURL
        self.explorerURL = decoration.explorerURL
        self.logoURL = decoration.logoURL
        self.discordURL = decoration.discordURL
        self.telegramURL = decoration.telegramURL
        self.twitterURL = decoration.twitterURL
        self.amount = 0
        self.decimals = decoration.decimals
        self.decimalAmount = 0
        self.usdValue = decoration.usdValue
        self.totalUSDValue = 0
        self.algoPriceChangePercentage = decoration.algoPriceChangePercentage
        self.isAvailableOnDiscover = decoration.isAvailableOnDiscover
    }
}

extension CollectibleAsset {
    public func update(with asset: StandardAsset) {
        if id != asset.id { return }

        isFrozen = asset.isFrozen ?? isFrozen
        isDestroyed = asset.isDestroyed
        optedInAtRound = asset.optedInAtRound ?? optedInAtRound
        creator = asset.creator ?? creator
        name = asset.naming.name ?? name
        unitName = asset.naming.unitName ?? unitName
        total = asset.total ?? total
        totalSupply = asset.totalSupply ?? totalSupply
        verificationTier = asset.verificationTier
        url = asset.url ?? url
        projectURL = asset.projectURL ?? projectURL
        explorerURL = asset.explorerURL ?? explorerURL
        logoURL = asset.logoURL ?? logoURL
        discordURL = asset.discordURL ?? discordURL
        telegramURL = asset.telegramURL ?? telegramURL
        twitterURL = asset.twitterURL ?? twitterURL
        amount = asset.amount
        decimals = asset.decimals
        decimalAmount = asset.decimalAmount
        usdValue = asset.usdValue ?? usdValue
        totalUSDValue = asset.totalUSDValue ?? totalUSDValue
        algoPriceChangePercentage = asset.algoPriceChangePercentage
        isAvailableOnDiscover = asset.isAvailableOnDiscover
    }

    public func update(with asset: CollectibleAsset) {
        if id != asset.id { return }

        isFrozen = asset.isFrozen ?? isFrozen
        isDestroyed = asset.isDestroyed
        optedInAtRound = asset.optedInAtRound ?? optedInAtRound
        creator = asset.creator ?? creator
        name = asset.naming.name ?? name
        unitName = asset.naming.unitName ?? unitName
        total = asset.total ?? total
        totalSupply = asset.totalSupply ?? totalSupply
        verificationTier = asset.verificationTier
        thumbnailImage = asset.thumbnailImage ?? thumbnailImage
        mediaType = asset.mediaType
        standard = asset.standard ?? standard
        media = asset.media.isEmpty ? media : asset.media
        title = asset.title ?? title
        collection = asset.collection ?? collection
        url = asset.url ?? url
        description = asset.description ?? description
        properties = asset.properties.isNilOrEmpty ? properties : asset.properties
        projectURL = asset.projectURL ?? projectURL
        explorerURL = asset.explorerURL ?? explorerURL
        logoURL = asset.logoURL ?? logoURL
        discordURL = asset.discordURL ?? discordURL
        telegramURL = asset.telegramURL ?? telegramURL
        twitterURL = asset.twitterURL ?? twitterURL
        amount = asset.amount
        decimals = asset.decimals
        decimalAmount = asset.decimalAmount
        usdValue = asset.usdValue ?? usdValue
        totalUSDValue = asset.totalUSDValue ?? totalUSDValue
        algoPriceChangePercentage = asset.algoPriceChangePercentage
        isAvailableOnDiscover = asset.isAvailableOnDiscover
    }
}

extension CollectibleAsset {
    public func isUSDC(for network: ALGAPI.Network) -> Bool {
        id == ALGAsset.usdcAssetID(network)
    }
}

extension CollectibleAsset: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension CollectibleAsset: Comparable {
    public static func == (lhs: CollectibleAsset, rhs: CollectibleAsset) -> Bool {
        return lhs.id == rhs.id &&
            lhs.amount == rhs.amount &&
            lhs.isFrozen == rhs.isFrozen &&
            lhs.isDestroyed == rhs.isDestroyed &&
            lhs.name == rhs.name &&
            lhs.unitName == rhs.unitName &&
            lhs.decimals == rhs.decimals &&
            lhs.usdValue == rhs.usdValue &&
            lhs.total == rhs.total &&
            lhs.verificationTier == rhs.verificationTier &&
            lhs.thumbnailImage == rhs.thumbnailImage &&
            lhs.title == rhs.title &&
            lhs.collection?.name == rhs.collection?.name &&
            lhs.optedInAtRound == rhs.optedInAtRound
    }

    public static func < (lhs: CollectibleAsset, rhs: CollectibleAsset) -> Bool {
        return lhs.id < rhs.id
    }
}
