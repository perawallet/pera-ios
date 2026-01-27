// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapPricingServiceTests.swift

import Testing
@testable import pera_wallet_core
@testable import pera_staging

@Suite
struct SwapPricingServiceTests {
    
    @Test
    func test_price_returnsFormattedPrice() {
            // Given
        let assetIn = AssetDecoration(asset: MockAsset(id: 0, name: "ALGO"))
        let assetOut = AssetDecoration(asset: MockAsset(id: 31566704, name: "USDC"))
        
        let quote = SwapQuote(price: 2,assetIn: assetIn, assetOut: assetOut)
        let service = SwapPricingService()
        
        // When
        let result = service.price(for: quote)
        
        // Then
        #expect(result != "-")
        #expect(result.contains("2 USDC per ALGO"), "Price should contain assetIn, assetOut and price")
    }
    
    @Test
    func test_price_returnsDashForNilQuote() {
        // Given
        let service = SwapPricingService()
        
        // When
        let result = service.price(for: nil)
        
        // Then
        #expect(result == "-", "Price should return '-' for nil quote")
    }
}


final class MockAsset: Asset {
    var id: pera_wallet_core.AssetID
    
    var amount: UInt64
    
    var isFrozen: Bool?
    
    var isDestroyed: Bool
    
    var optedInAtRound: UInt64?
    
    var creator: pera_wallet_core.AssetCreator?
    
    var decimals: Int
    
    var total: UInt64?
    
    var totalSupply: Decimal?
    
    var category: UInt64?
    
    var url: String?
    
    var verificationTier: pera_wallet_core.AssetVerificationTier
    
    var projectURL: URL?
    
    var explorerURL: URL?
    
    var logoURL: URL?
    
    var description: String?
    
    var decimalAmount: Decimal
    
    var usdValue: Decimal?
    
    var totalUSDValue: Decimal?
    
    var state: pera_wallet_core.AssetState
    
    var naming: pera_wallet_core.AssetNaming
    
    var amountWithFraction: Decimal
    
    var discordURL: URL?
    
    var telegramURL: URL?
    
    var twitterURL: URL?
    
    var algoPriceChangePercentage: Decimal
    
    var isAvailableOnDiscover: Bool
    
    var isAlgo: Bool
    
    var isFault: Bool
    
    var isFavorited: Bool?
    
    var isPriceAlertEnabled: Bool?
    
    func isUSDC(for network: pera_wallet_core.ALGAPI.Network) -> Bool {
        return id == 31566704
    }
    
    init(id: pera_wallet_core.AssetID, name: String, decimals: Int = 0) {
        self.id = id
        self.naming = AssetNaming(id: id, name: name, unitName: name)
        self.amount = UInt64(0.0)
        self.verificationTier = .verified
        self.isDestroyed = false
        self.decimals = decimals
        self.decimalAmount = Decimal(0.0)
        self.state = .ready
        self.amountWithFraction = Decimal(0.0)
        self.algoPriceChangePercentage = Decimal(0.0)
        self.isAvailableOnDiscover = false
        self.isAlgo = id == 0
        self.isFault = false
    }
    
    
}
