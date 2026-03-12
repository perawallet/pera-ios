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

//   ProviderSheetViewModelTests.swift

import Testing
@testable import pera_wallet_core
@testable import pera_staging

@Suite
struct ProviderSheetViewModelTests {
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    @Test
    func sheetHeight_withProviders_calculatesCorrectHeight() {
        // Given
        let providersCount = 3
        let providers = Array(repeating: SwapProviderV2.mock(), count: providersCount)
        let viewModel = ProviderSheetViewModel(
            selectedProvider: .auto,
            availableProviders: providers,
            quoteList: nil
        )

        // When
        let result = viewModel.sheetHeight

        // Then
        #expect(result == Double(150 + ((providersCount + 1) * 72)))
    }
    
    @Test
    func sheetHeight_withoutProviders_returnsBaseHeight() {
        // Given
        let viewModel = ProviderSheetViewModel(
            selectedProvider: .auto,
            availableProviders: [],
            quoteList: nil
        )

        // When
        let result = viewModel.sheetHeight

        // Then
        #expect(result == Double(150 + 72))
    }
    
    @Test
    func quotePrimaryValue_whenQuoteListIsNil_returnsDash() {
        // Given
        let viewModel = ProviderSheetViewModel(
            selectedProvider: .auto,
            availableProviders: [],
            quoteList: nil
        )

        // When
        let result = viewModel.quotePrimaryValue(for: "provider")

        // Then
        #expect(result == "-")
    }
    
    @Test
    func quotePrimaryValue_whenProviderNotFound_returnsDash() {
        // Given
        let quote = SwapQuote()
        let viewModel = ProviderSheetViewModel(
            selectedProvider: .auto,
            availableProviders: [],
            quoteList: [quote]
        )

        // When
        let result = viewModel.quotePrimaryValue(for: "provider")

        // Then
        #expect(result == "-")
    }
    
    @Test
    func quotePrimaryValue_whenProviderFound_formatsAmountCorrectly() {
        // Given
        let quote = SwapQuote(assetOut: AssetDecoration(asset: MockAsset(id: 123, name: "MockAsset", decimals: 4)),amountOut: "123456", provider: .unknown("provider"))
        
        let viewModel = ProviderSheetViewModel(
            selectedProvider: .auto,
            availableProviders: [],
            quoteList: [quote]
        )

        // When
        let result = viewModel.quotePrimaryValue(for: "provider")

        // Then
        #expect(result == "12\(decimalSeparator)3456")
    }
    
    @Test
    func quoteSecondaryValue_whenQuoteListIsNil_returnsDash() {
        // Given
        let viewModel = ProviderSheetViewModel(
            selectedProvider: .auto,
            availableProviders: [],
            quoteList: nil
        )

        // When
        let result = viewModel.quoteSecondaryValue(for: "provider")

        // Then
        #expect(result == "-")
    }
}
