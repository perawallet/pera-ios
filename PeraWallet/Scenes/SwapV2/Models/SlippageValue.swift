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

//   SlippageValue.swift

enum SlippageValue: Equatable, Hashable {
    case custom(value: Double)
    case c05, c1, c2, c5
    
    var title: String {
        switch self {
        case .custom: "Custom"
        case .c05: "0.5%"
        case .c1: "1%"
        case .c2: "2%"
        case .c5: "5%"
        }
    }
    
    var value: Double {
        switch self {
        case .custom(value: let value): value
        case .c05: 0.005
        case .c1: 0.01
        case .c2: 0.02
        case .c5: 0.05
        }
    }
    
    static var allDefaultCases: [SlippageValue] {
        [.c05, .c1, .c2, .c5]
    }
    
    static var allCases: [SlippageValue] {
        [.custom(value: 0), .c05, .c1, .c2, .c5]
    }
    
    static func == (lhs: SlippageValue, rhs: SlippageValue) -> Bool {
        switch (lhs, rhs) {
        case (.custom, .custom),
            (.c05, .c05),
            (.c1, .c1),
            (.c2, .c2),
            (.c5, .c5):
            return true
        default:
            return false
        }
    }
}
