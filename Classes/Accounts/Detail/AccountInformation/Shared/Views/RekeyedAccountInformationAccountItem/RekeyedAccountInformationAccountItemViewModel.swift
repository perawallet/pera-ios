// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyedAccountInformationAccountItemViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct RekeyedAccountInformationAccountItemViewModel: ViewModel {
    private(set) var from: AccountListItemWithActionViewModel?
    private(set) var to: AccountListItemWithActionViewModel?

    init(
        from: Account,
        to: Account?
    ) {
        bindFrom(from)
        bindTo(from: from, to: to)
    }
}

extension RekeyedAccountInformationAccountItemViewModel {
    private mutating func bindFrom(_ from: Account) {
        self.from = AccountInformationCopyAccountItemViewModel(from)
    }

    private mutating func bindTo(from: Account, to: Account?) {
        if let to {
            self.to = AccountInformationUndoRekeyAccountItemViewModel(to)
        } else {
            let authAddress = from.authAddress.someString
            self.to = AccountInformationNoAuthAccountItemViewModel(authAddress)
        }
    }
}
