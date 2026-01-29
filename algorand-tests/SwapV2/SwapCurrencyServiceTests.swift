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

//   SwapCurrencyServiceTests.swift

import Testing
@testable import pera_wallet_core
@testable import pera_staging

@Suite
struct SwapCurrencyServiceTests {
    
    @Test
    func fiatValueText_fromAlgo_formatsFiatAmount() {
        // Given
        let currency = MockCurrencyProvider(
            fiatValue: .available(makeFiatCurrency(algoValue: 2, usdValue: 1, id: .fiat(localValue: "31566704"), name: "USDC", symbol: nil)),
            algoValue: .available(makeAlgoCurrency())
        )
        let service = SwapCurrencyService(currency: currency)

        // When
        let result = service.fiatValueText(fromAlgo: 1)

        // Then
        #expect(result.isEmpty == false)
    }
    
    @Test
    func algoValue_fromFiat_convertsUsingExchangeRate() {
        // Given
        let currency = MockCurrencyProvider(
            fiatValue: .available(makeFiatCurrency(algoValue: 2, usdValue: 1, id: .fiat(localValue: "31566704"), name: "USDC", symbol: nil)),
            algoValue: .available(makeAlgoCurrency())
        )
        let service = SwapCurrencyService(currency: currency)

        // When
        let result = service.algoValue(fromFiat: 2)

        // Then
        #expect(result > 0)
    }
    
    @Test
    func fiatValueText_fromUSDC_formatsFiatAmount() {
        // Given
        let currency = MockCurrencyProvider(
            fiatValue: .available(makeFiatCurrency(algoValue: 2, usdValue: 1, id: .fiat(localValue: "31566704"), name: "USDC", symbol: nil)),
            algoValue: .available(makeAlgoCurrency())
        )
        let service = SwapCurrencyService(currency: currency)

        // When
        let result = service.fiatValueText(fromUSDC: 10)

        // Then
        #expect(result.isEmpty == false)
    }
    
    @Test
    func fiatValueText_fromAsset_algoAsset_usesAlgoConversion() {
        // Given
        let asset = MockAsset(id: 0, name: "ALGO")
        let currency = MockCurrencyProvider(
            fiatValue: .available(makeFiatCurrency(algoValue: 2, usdValue: 1, id: .fiat(localValue: "31566704"), name: "USDC", symbol: nil)),
            algoValue: .available(makeAlgoCurrency())
        )
        let service = SwapCurrencyService(currency: currency)

        // When
        let result = service.fiatValueText(fromAsset: asset, with: 1)

        // Then
        #expect(result.isEmpty == false)
    }
    
    @Test
    func fiatValueText_fromAsset_nonAlgoAsset_usesAssetConversion() {
        // Given
        let asset = MockAsset(id: 12456, name: "MockAsset")
        let currency = MockCurrencyProvider(
            fiatValue: .available(makeFiatCurrency(algoValue: 2, usdValue: 1, id: .fiat(localValue: "31566704"), name: "USDC", symbol: nil)),
            algoValue: .available(makeAlgoCurrency())
        )
        let service = SwapCurrencyService(currency: currency)

        // When
        let result = service.fiatValueText(fromAsset: asset, with: 5)

        // Then
        #expect(result.isEmpty == false)
    }
    
    @Test
    func fiatFormat_returnsEmptyString_whenFiatCurrencyIsMissing() {
        // Given
        let currency = MockCurrencyProvider(
            fiatValue: nil,
            algoValue: .available(makeAlgoCurrency())
        )
        let service = SwapCurrencyService(currency: currency)

        // When
        let result = service.fiatFormat(with: 10)

        // Then
        #expect(result == "")
    }
    
    
    // MARK: Helpers
    
    private func makeFiatCurrency(
        algoValue: Decimal,
        usdValue: Decimal,
        id: CurrencyID,
        name: String?,
        symbol: String?
    ) -> MockRemoteCurrency {
        MockRemoteCurrency(
            id: id,
            name: name,
            symbol: symbol,
            isFault: false,
            algoValue: algoValue,
            usdValue: usdValue,
            lastUpdateDate: Date()
        )
    }
    
    private func makeAlgoCurrency() -> MockRemoteCurrency {
        MockRemoteCurrency(
            id: .algo(),
            name: "ALGO",
            symbol: nil,
            isFault: false,
            algoValue: 1,
            usdValue: nil,
            lastUpdateDate: Date()
        )
    }
}
