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

//   RekeyedAccountSelectionListHeaderViewModel.swift

import Foundation
import MacaroonUIKit

struct RekeyedAccountSelectionListHeaderViewModel: ViewModel {
    private(set) var title: TextProvider?

    init(accounts: [Account]) {
        bindTitle(accounts)
    }
}

extension RekeyedAccountSelectionListHeaderViewModel {
    private mutating func bindTitle(_ accounts: [Account]) {
        title = String(format: String(localized: "rekeyed-account-selection-list-header-body"), accounts.count).bodyRegular()
    }
}
