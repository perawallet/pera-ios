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

//   AlreadyImportedAddressListItemViewModel.swift

import Foundation
import MacaroonUIKit
import pera_wallet_core

struct AlreadyImportedAddressListItemViewModel:
    ViewModel,
    Hashable {
    private(set) var title: TextProvider?

    init(
        _ recoveredAddress: RecoveredAddress
    ) {
        bindTitle(recoveredAddress)
    }
}

extension AlreadyImportedAddressListItemViewModel {
    private mutating func bindTitle(
        _ recoveredAddress: RecoveredAddress
    ) {
        self.title = recoveredAddress.address.shortAddressDisplay
        
    }
}

extension AlreadyImportedAddressListItemViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title?.string)
    }

    static func == (
        lhs: AlreadyImportedAddressListItemViewModel,
        rhs: AlreadyImportedAddressListItemViewModel
    ) -> Bool {
        return lhs.title?.string == rhs.title?.string
    }
}
