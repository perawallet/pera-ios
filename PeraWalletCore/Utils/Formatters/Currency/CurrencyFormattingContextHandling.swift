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

//   CurrencyFormattingContextHandling.swift

import Foundation

public protocol CurrencyFormattingContextHandling {
    func makeRules(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextRules

    func makeInput(
        _ rawNumber: NSDecimalNumber,
        for currency: LocalCurrency?
    ) -> CurrencyFormattingContextInput
}

public struct CurrencyFormattingContextRules {
    public var roundingMode: RoundingMode?
    public var minimumFractionDigits: Int?
    public var maximumFractionDigits: Int?
    
    public init() {
        
    }
}

extension CurrencyFormattingContextRules {
    public typealias RoundingMode = NumberFormatter.RoundingMode
}

/// <todo> Rename to `NumberFormattingContextInput`, since it is also used for `CollectibleAmountFormatter`?
public protocol CurrencyFormattingContextInput {
    var number: NSDecimalNumber { get }
    var prefix: String? { get }
    var suffix: String? { get }
}

extension NSDecimalNumber: CurrencyFormattingContextInput {
    public var number: NSDecimalNumber {
        return self
    }
    public var prefix: String? {
        return nil
    }
    public var suffix: String? {
        return nil
    }
}

extension NumberRoundingResult: CurrencyFormattingContextInput {
    public var prefix: String? {
        return nil
    }
    public var suffix: String? {
        return abbreviation?.short
    }
}

public struct FiatCurrencyMinimumNonZeroInput: CurrencyFormattingContextInput {
    public let number: NSDecimalNumber = 0.000001
    public let prefix: String? = "<"
    public let suffix: String? = nil
}
