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
