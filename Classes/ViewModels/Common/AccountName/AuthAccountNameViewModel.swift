// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AuthAccountNameViewModel.swift

import UIKit
import MacaroonUIKit

final class AuthAccountNameViewModel: PairedViewModel {
    private(set) var accountType: AccountType
    private(set) var address: String?
    
    init(_ model: Account) {
        accountType = model.type
        bindAddress(model)
    }
}

extension AuthAccountNameViewModel {
    private func bindAddress(_ account: Account) {
        address = account.authAddress.unwrap(or: account.address).shortAddressDisplay()
    }
}
