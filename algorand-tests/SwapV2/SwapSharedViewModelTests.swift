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

//   SwapSharedViewModelTests.swift

import Testing
@testable import pera_wallet_core
@testable import pera_staging

@Suite
struct SwapSharedViewModelTests {
    
    @Test
    func test_shouldShowSwapButton_whenAllConditionsMet() {
        // Given
        let vm = makeViewModel()
        
        // When
        let result = vm.shouldShowSwapButton
        
        // Then
        #expect(result == true)
    }
    
    @Test
    func test_shouldShowSwapButton_whenLoadingOrInsufficientBalance() {
        // Given
        let vm = makeViewModel(isBalanceNotSufficient: true)
        
        // When
        let result = vm.shouldShowSwapButton
        
        // Then
        #expect(result == false)
    }
    
    @Test
    func test_switchAssets_swapsAssetsAndResetsTexts() {
        // Given
        let vm = makeViewModel()
        let oldIn = vm.selectedAssetIn
        let oldOut = vm.selectedAssetOut
        var called = false
        
        // When
        vm.switchAssets { called = true }
        
        // Then
        #expect(vm.selectedAssetIn.asset.id == oldOut.asset.id)
        #expect(vm.selectedAssetIn.asset.naming.name == oldOut.asset.naming.name)
        #expect(vm.selectedAssetOut.asset.id == oldIn.asset.id)
        #expect(vm.selectedAssetOut.asset.naming.name == oldIn.asset.naming.name)
        #expect(vm.receivingText.isEmpty)
        #expect(vm.receivingTextInSecondaryCurrency.isEmpty)
        #expect(vm.payingTextInSecondaryCurrency.isEmpty)
        #expect(called == true)
    }
    
    @Test
    func test_confirmSwapModel_returnsNilWhenNoActiveProvider() {
        // Given
        let vm = makeViewModel()
        vm.availableProviders = nil
        
        // When
        let model = vm.confirmSwapModel()
        
        // Then
        #expect(model == nil)
    }
    
    @Test
    func test_confirmSwapModel_returnsViewModelWhenActiveProviderExists() {
        // Given
        let vm = makeViewModel()
        let provider = SwapProviderV2.mock()
        vm.availableProviders = [provider]
        vm.selectedProvider = .provider(provider.name)
        vm.selectedQuote = SwapQuote()
        
        // When
        let model = vm.confirmSwapModel()
        
        // Then
        #expect(model != nil)
        #expect(model?.selectedAssetIn.asset.id == 123)
        #expect(model?.selectedAssetOut.asset.id == 456)
        #expect(model?.provider.name == "MockProvider")
    }
    
    @Test
    func test_filterPayingText_removesInvalidCharacters() {
        // Given
        let vm = makeViewModel()
        
        // When
        let filtered = vm.filterPayingText("12a,3b4")
        
        // Then
        #expect(filtered == "12,34")
    }
    
    @Test
    func test_resetTextFields_setsAllFieldsToDefault() {
        // Given
        let vm = makeViewModel()
        vm.payingText = "123"
        vm.receivingText = "456"
        #expect(vm.payingText == "123")
        #expect(vm.receivingText == "456")
        
        // When
        vm.resetTextFields()
        
        // Then
        #expect(vm.payingText.isEmpty)
        #expect(vm.payingTextInSecondaryCurrency.isEmpty)
        #expect(vm.receivingText.isEmpty)
        #expect(vm.receivingTextInSecondaryCurrency.isEmpty)
    }
    
    
    // MARK: - Helpers
    
    private func makeViewModel(
        payingText: String = "10",
        receivingText: String = "20",
        isBalanceNotSufficient: Bool = false,
        isLoadingPayAmount: Bool = false,
        isLoadingReceiveAmount: Bool = false
    ) -> SwapSharedViewModel {
        let currency = MockCurrencyProvider()
        let sharedData = MockSharedDataController()
        let account = Account(address: "A1")
        let assetIn = AssetItem(asset: MockAsset(id: 123, name: "MockAssetIn"), currency: currency, currencyFormatter: CurrencyFormatter(), isAmountHidden: false)
        let assetOut = AssetItem(asset: MockAsset(id: 456, name: "MockAssetOut"), currency: currency, currencyFormatter: CurrencyFormatter(), isAmountHidden: false)
        let vm = SwapSharedViewModel(
            selectedAccount: account,
            selectedAssetIn: assetIn,
            selectedAssetOut: assetOut,
            selectedNetwork: .mainnet,
            currency: currency,
            sharedDataController: sharedData
        )
        vm.payingText = payingText
        vm.receivingText = receivingText
        vm.isBalanceNotSufficient = isBalanceNotSufficient
        vm.isLoadingPayAmount = isLoadingPayAmount
        vm.isLoadingReceiveAmount = isLoadingReceiveAmount
        return vm
    }
}
