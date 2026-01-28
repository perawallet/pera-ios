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

//   SwapConfirmViewModelTests.swift

import Testing
@testable import pera_wallet_core
@testable import pera_staging

@Suite
struct SwapConfirmViewModelTests {
    
    @Test
    func test_highPriceImpactWarning_nilForLowImpact() {
        // Given
        let vm = makeViewModel(priceImpact: "3%")
        
        // When
        let result = vm.highPriceImpactWarning
        
        // Then
        #expect(result == nil)
    }
    
    @Test
    func test_highPriceImpactWarning_warningForMediumImpact() {
        // Given
        let vm = makeViewModel(priceImpact: "10%")
        
        // When
        let result = vm.highPriceImpactWarning
        
        // Then
        #expect(result == "swap-price-impact-warning-message")
    }
    
    @Test
    func test_highPriceImpactWarning_warningForHighImpact() {
        // Given
        let vm = makeViewModel(priceImpact: "20%")
        
        // When
        let result = vm.highPriceImpactWarning
        
        // Then
        #expect(result == "swap-price-impact-greater-than-15-warning-message")
    }
    
    @Test
    func test_highPriceImpactWarning_nilIfInvalidPriceImpact() {
        // Given
        let vm = makeViewModel(priceImpact: "NaN")
        
        // When
        let result = vm.highPriceImpactWarning
        
        // Then
        #expect(result == nil)
    }
    
    @Test
    func test_isSwapDisabled_falseForLowImpact() {
        // Given
        let vm = makeViewModel(priceImpact: "5%")
        
        // When
        let result = vm.isSwapDisabled
        
        // Then
        #expect(result == false)
    }
    
    @Test
    func test_isSwapDisabled_trueForHighImpact() {
        // Given
        let vm = makeViewModel(priceImpact: "16%")
        
        // When
        let result = vm.isSwapDisabled
        
        // Then
        #expect(result == true)
    }
    
    @Test
    func test_isSwapDisabled_falseIfInvalidPriceImpact() {
        // Given
        let vm = makeViewModel(priceImpact: "abc")
        
        // When
        let result = vm.isSwapDisabled
        
        // Then
        #expect(result == false)
    }
    
    @Test
    func test_swapInfoSheet_idValues() {
        #expect(SwapInfoSheet.slippageTolerance.id == "slippageTolerance")
        #expect(SwapInfoSheet.priceImpact.id == "priceImpact")
        #expect(SwapInfoSheet.exchangeFee.id == "exchangeFee")
    }
    
    @Test
    func test_swapInfoSheet_titleValues() {
        #expect(SwapInfoSheet.slippageTolerance.title == "swap-slippage-title")
        #expect(SwapInfoSheet.priceImpact.title == "swap-price-impact-title")
        #expect(SwapInfoSheet.exchangeFee.title == "title-exchange-fee")
    }

    @Test
    func test_swapInfoSheet_textValues() {
        #expect(SwapInfoSheet.slippageTolerance.text == "swap-slippage-tolerance-info-body")
        #expect(SwapInfoSheet.priceImpact.text == "swap-price-impact-info-body")
        #expect(SwapInfoSheet.exchangeFee.text == "swap-exchange-fee-info-body")
    }

    @Test
    func test_swapInfoSheet_heightValues() {
        #expect(SwapInfoSheet.slippageTolerance.height == 320)
        #expect(SwapInfoSheet.priceImpact.height == 250)
        #expect(SwapInfoSheet.exchangeFee.height == 280)
    }
    
    // MARK: - Helpers

    private func makeViewModel(
        priceImpact: String,
        confirmationState: ConfirmSlideButtonState = .idle
    ) -> SwapConfirmViewModel {
        SwapConfirmViewModel(
            selectedAccount: Account(address: "1234567890abcdefghij"),
            selectedAssetIn: AssetItem(asset: MockAsset(id: 123, name: "MockAssetIn"), currency: MockCurrencyProvider(), currencyFormatter: CurrencyFormatter(), isAmountHidden: false),
            selectedAssetOut: AssetItem(asset: MockAsset(id: 456, name: "MockAssetOut"), currency: MockCurrencyProvider(), currencyFormatter: CurrencyFormatter(), isAmountHidden: false),
            selectedAssetInAmount: "1",
            selectedAssetOutAmount: "2",
            selectedAssetInAmountInSecondaryCurrency: "1",
            selectedAssetOutAmountInSecondaryCurrency: "2",
            price: "2",
            provider: SwapProviderV2.mock(),
            slippageTolerance: "0.5%",
            priceImpact: priceImpact,
            minimumReceived: "1",
            exchangeFee: "0.01",
            peraFee: "0.005",
            confirmationState: confirmationState,
            selectedNetwork: .mainnet
        )
    }
}
