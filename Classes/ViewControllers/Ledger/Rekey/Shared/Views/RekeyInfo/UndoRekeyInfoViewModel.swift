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

//   UndoRekeyInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct UndoRekeyInfoViewModel: RekeyInfoViewModel {
    private(set) var title: TextProvider?
    private(set) var sourceAccountItem: AccountListItemViewModel?
    private(set) var authAccountItem: AccountListItemViewModel?

    init(
        sourceAccount: Account,
        authAccount: Account
    ) {
        bindTitle()
        bindSourceAccountItem(sourceAccount)
        bindAuthAccountItem(authAccount)
    }
}

extension UndoRekeyInfoViewModel {
    private mutating func bindTitle() {
        title =
            String(localized: "title-undo-rekey")
                .bodyRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindSourceAccountItem(_ sourceAccount: Account) {
        sourceAccountItem = AccountListItemViewModel(sourceAccount)
    }

    private mutating func bindAuthAccountItem(_ authAccount: Account) {
        var viewModel = AccountListItemViewModel(authAccount)
        viewModel.bindIcon(authAccount.underlyingTypeImage)
        if authAccount.name == authAccount.address.shortAddressDisplay {
            viewModel.title = AccountPreviewTitleViewModel(primaryTitle: viewModel.title?.primaryTitle?.string, secondaryTitle: nil)
        }
        authAccountItem = viewModel
    }
}
