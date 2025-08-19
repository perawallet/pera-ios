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

public struct RecoveredAddress {
    public let address: String
    public let accountIndex: UInt32
    public let addressIndex: UInt32
    public let mainCurrency: Double
    public let secondaryCurrency: Double
    public let alreadyImported: Bool
    
    public init(address: String, accountIndex: UInt32, addressIndex: UInt32, mainCurrency: Double, secondaryCurrency: Double, alreadyImported: Bool) {
        self.address = address
        self.accountIndex = accountIndex
        self.addressIndex = addressIndex
        self.mainCurrency = mainCurrency
        self.secondaryCurrency = secondaryCurrency
        self.alreadyImported = alreadyImported
    }
}

