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

//   SwapType.swift

import Foundation

enum SwapType:
    String,
    Codable {
    case fixedInput = "fixed-input" /// <note> Input is from the user's selected asset
    case fixedOutput = "fixed-output" /// <note> Input is from the selected pool

    mutating func toggle() {
        switch self {
        case .fixedInput:
            self = .fixedOutput
        case .fixedOutput:
            self = .fixedInput
        }
    }
}
