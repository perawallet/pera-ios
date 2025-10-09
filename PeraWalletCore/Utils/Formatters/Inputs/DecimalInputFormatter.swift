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

//   DecimalInputFormatter.swift

import Foundation

public struct DecimalInputFormatter {
    /// Filters a string to allow only digits and a single dot
    public static func format(_ input: String) -> String {
        var filtered = ""
        var hasDot = false

        for c in input {
            if c.isNumber {
                filtered.append(c)
            } else if c == "." && !hasDot {
                filtered.append(c)
                hasDot = true
            }
        }

        return filtered
    }
}
