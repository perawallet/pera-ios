// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ExportAccountListAccountsHeaderViewModel.swift

import UIKit
import MacaroonUIKit

struct ExportAccountListAccountsHeaderViewModel:
    ViewModel {
    private(set) var info: TextProvider?
    private(set) var actionStyle: ButtonStyle?

    init(
        accountsCount: Int,
        state: ExportAccountListAccountHeaderItemState
    ) {
        bindInfo(accountsCount)
        bindAction(state)
    }
}

extension ExportAccountListAccountsHeaderViewModel {
    private mutating func bindInfo(
        _ accountsCount: Int
    ) {
        let info: String

        if accountsCount < 2 {
            info = "title-plus-account-singular-count".localized(params: "\(accountsCount)")
        } else {
            info = "title-plus-account-count".localized(params: "\(accountsCount)")
        }

        self.info = info.bodyMedium(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindAction(
        _ state: ExportAccountListAccountHeaderItemState
    ) {
        let title: NSAttributedString
        let icon: Image

        switch state {
        case .selectAll:
            title =
                "title-select-all"
                    .localized
                    .bodyMedium(lineBreakMode: .byTruncatingTail)
            icon = "icon-checkbox-unselected"
        case .partialSelection:
            title =
                "title-select-all"
                    .localized
                    .bodyMedium(lineBreakMode: .byTruncatingTail)
            icon = "icon-checkbox-partial-selected"
        case .unselectAll:
            title =
                "title-unselect-all"
                    .localized
                    .bodyMedium(lineBreakMode: .byTruncatingTail)
            icon = "icon-checkbox-selected"
        }

        actionStyle = [
            .title(title),
            .icon([ .normal(icon) ])
        ]
    }
}
