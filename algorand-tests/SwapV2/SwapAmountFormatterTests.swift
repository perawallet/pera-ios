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

//   SwapAmountFormatterTests.swift

import Testing

@testable import pera_wallet_core
@testable import pera_staging

@Suite
struct SwapAmountFormatterTests {

    let formatter = SwapAmountFormatter()
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    // MARK: - string(from:maxFractionDigits:)
    
    @Test
    func string_formatsDecimalWithoutTrailingZeros() {
        let result = formatter.string(from: Decimal(string: "10\(decimalSeparator)000")!)
        #expect(result == "10")
    }
    
    @Test
    func string_respectsMaxFractionDigits() {
        let result = formatter.string(
            from: Decimal(string: "1.123456789")!,
            maxFractionDigits: 4
        )
        #expect(result == "1\(decimalSeparator)1235")
    }
    
    @Test
    func string_returnsNilForInvalidDecimal() {
        let result = formatter.string(from: Decimal.nan)
        #expect(result == "NaN")
    }
    
    // MARK: - percentage(from:fractionDigits:)

    @Test
    func percentage_formatsCorrectly() {
        let result = formatter.percentage(
            from: Decimal(string: "0.1234")!,
            fractionDigits: 2
        )
        #expect(result == "12\(decimalSeparator)34%")
    }

    @Test
    func percentage_usesFallbackOnFailure() {
        let result = formatter.percentage(from: Decimal.nan)
        #expect(result == "NaN")
    }
    
    // MARK: - numericValue(from:)

    @Test
    func numericValue_parsesValidNumber() {
        let result = formatter.numericValue(from: "123\(decimalSeparator)45")
        #expect(result == 123.45)
    }

    @Test
    func numericValue_returnsZeroForInvalidInput() {
        let result = formatter.numericValue(from: "abc")
        #expect(result == 0)
    }

    @Test
    func numericValue_handlesCommaDecimalSeparator() {
        let result = formatter.numericValue(from: "1\(decimalSeparator)5")
        #expect(result == 1.5)
    }
    
}
