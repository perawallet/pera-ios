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

//
//   LedgerAccountSelectionViewModel.swift

import MacaroonUIKit

final class LedgerAccountSelectionViewModel: ViewModel {
    private(set) var detail: TextProvider?
    private(set) var accountCount: TextProvider?
    private(set) var buttonText: String?
    private(set) var isEnabled: Bool = false

    init(accounts: [Account], isMultiSelect: Bool, selectedCount: Int) {
        bindDetail(isMultiSelect)
        bindAccountCount(accounts)
        bindButtonText(from: isMultiSelect, and: selectedCount)
        bindIsEnabled(selectedCount)
    }

    private func bindButtonText(from isMultiSelect: Bool, and selectedCount: Int) {
        if isMultiSelect {
            buttonText =
                selectedCount <= 1
                ? String(localized: "ledger-account-selection-verify")
                : String(localized: "ledger-account-selection-verify-plural")
        } else {
            buttonText = String(localized: "title-continue")
        }
    }

    private func bindIsEnabled(_ selectedCount: Int) {
        isEnabled = selectedCount > 0
    }

    private func bindDetail(_ isMultiSelect: Bool) {
        let text =
            isMultiSelect
            ? String(localized: "ledger-account-selection-detail")
            : String(localized: "ledger-account-selection-detail-rekey")
        detail = text.bodyRegular()
    }

    private func bindAccountCount(_ accounts: [Account]) {
        accountCount = String(format: String(localized: "ledger-account-selection-title"), accounts.count).bodyLargeMedium()
    }
}
