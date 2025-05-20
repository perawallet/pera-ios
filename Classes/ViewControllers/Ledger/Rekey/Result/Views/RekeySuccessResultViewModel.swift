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

//   RekeySuccessResultViewModel.swift

import Foundation
import MacaroonUIKit

struct RekeySuccessResultViewModel: ResultViewModel {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init(sourceAccount: Account) {
        bindIcon()
        bindTitle()
        bindBody(sourceAccount)
    }
}

extension RekeySuccessResultViewModel {
    private mutating func bindIcon() {
        icon = "check"
    }

    private mutating func bindTitle() {
        let aTitle =
            String(localized: "ledger-rekey-success-title")
                .titleMedium()
        title = aTitle
    }

    private mutating func bindBody(_ account: Account) {
        let accountName = account.primaryDisplayName
        let text = String(format: String(localized: "ledger-rekey-success-message"), accountName).bodyRegular()

        let highlightedTextAttributes = Typography.bodyMediumAttributes()
        let aBody = text.addAttributes(
            to: accountName,
            newAttributes: highlightedTextAttributes
        )

        body = aBody
    }
}
