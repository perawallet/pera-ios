// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapSlippage.swift

import Foundation

enum SwapSlippage:
    RawRepresentable,
    CaseIterable,
    Codable,
    Equatable {
    typealias SlippageAmount = Decimal

    case onePerThousand
    case fivePerThousand
    case onePercent
    case custom(SlippageAmount)

    var rawValue: Decimal {
        switch self {
        case .onePerThousand: return 0.001
        case .fivePerThousand: return 0.005
        case .onePercent: return 0.1
        case .custom(let aRawValue): return aRawValue
        }
    }

    static var allCases: [Self] = [
        .onePerThousand, .fivePerThousand, .onePercent
    ]

    init() {
        self = .fivePerThousand
    }

    init?(
        rawValue: Decimal
    ) {
        let foundCase = Self.allCases.first { $0.rawValue == rawValue }
        self = foundCase ?? .custom(rawValue)
    }
}
