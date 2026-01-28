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

//   PercentageValue.swift

enum PercentageValue: CaseIterable, Equatable, Hashable {
    case custom(value: Double)
    case p25, p50, p75, max
    
    var title: String {
        switch self {
        case .custom: "Custom"
        case .p25: "25%"
        case .p50: "50%"
        case .p75: "75%"
        case .max: "MAX"
        }
    }
    
    var value: Double {
        switch self {
        case .custom(value: let value): value
        case .p25: 0.25
        case .p50: 0.5
        case .p75: 0.75
        case .max: 1
        }
    }
    
    static var allCases: [PercentageValue] {
        [.p25, .p50, .p75, .max]
    }
}
