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

//   HDWalletAddressDetail.swift

import Foundation

public struct HDWalletAddressDetail: Codable {
    public let walletId: String
    public let account: UInt32
    public let change: UInt32
    public let keyIndex: UInt32
    public let derivationType: HDWalletDerivationType
    
    public init(
        walletId: String,
        account: UInt32,
        change: UInt32,
        keyIndex: UInt32,
        derivationType: HDWalletDerivationType = .peikert
    ) {
        self.walletId = walletId
        self.account = account
        self.change = change
        self.keyIndex = keyIndex
        self.derivationType = derivationType
    }
}

extension HDWalletAddressDetail: Equatable {
    public static func == (
        lhs: HDWalletAddressDetail,
        rhs: HDWalletAddressDetail
    ) -> Bool {
        lhs.walletId == rhs.walletId
    }
}
