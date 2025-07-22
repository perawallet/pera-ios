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

//   ChartSelectedPointViewModel.swift

struct ChartSelectedPointViewModel: Hashable {
    private let primaryValue: Double
    private let secondaryValue: Double
    let dateValue: String
    
    init(primaryValue: Double, secondaryValue: Double, dateValue: String) {
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
        self.dateValue = dateValue
    }
    
    func primaryValue(for remoteCurrency: RemoteCurrencyValue? = nil) -> Double {
        guard  let currency = try? remoteCurrency?.unwrap(), !currency.isAlgo else {
            return primaryValue
        }
        
        return secondaryValue
    }
    
    func secondaryValue(for remoteCurrency: RemoteCurrencyValue? = nil) -> Double {
        guard  let currency = try? remoteCurrency?.unwrap(), currency.isAlgo else {
            return secondaryValue
        }
        
        return primaryValue
    }
}
