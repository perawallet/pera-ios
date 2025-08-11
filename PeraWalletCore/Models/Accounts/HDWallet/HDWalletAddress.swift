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

//   HDWalletAddress.swift

import Foundation

public struct HDWalletAddress: Codable {
    public let walletId: String
    public let address: String
    public let publicKey: Data
    public let privateKey: Data
    
    public init(
        walletId: String,
        address: String,
        publicKey: Data,
        privateKey: Data
    ) {
        self.walletId = walletId
        self.address = address
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
}

extension HDWalletAddress: Equatable {
    public static func == (lhs: HDWalletAddress, rhs: HDWalletAddress) -> Bool {
        lhs.address == rhs.address && lhs.walletId == rhs.walletId
    }
}
