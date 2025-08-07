// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ChartSelectedPointHandler.swift

struct ChartSelectedPointHandler {
    static func resolveValues(
        primaryValue: Double,
        secondaryValue: Double,
        currency: RemoteCurrencyValue?
    ) -> (primary: Double, secondary: Double) {
        guard let currency = try? currency?.unwrap() else {
            return (primaryValue, secondaryValue)
        }

        if currency.isAlgo {
            return (primaryValue, secondaryValue)
        } else {
            return (secondaryValue, primaryValue)
        }
    }
}
