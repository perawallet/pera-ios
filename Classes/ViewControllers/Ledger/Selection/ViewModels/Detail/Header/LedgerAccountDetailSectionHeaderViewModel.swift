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
//   LedgerAccountDetailSectionHeaderViewModel.swift

import MacaroonUIKit

final class LedgerAccountDetailSectionHeaderViewModel: ViewModel {
    private(set) var headerTitle: String?

    init(section: LedgerAccountDetailDataSource.Section, account: Account) {
        bindHeaderTitle(section: section, account: account)
    }
}

extension LedgerAccountDetailSectionHeaderViewModel {
    private func bindHeaderTitle(section: LedgerAccountDetailDataSource.Section, account: Account) {
        switch section {
        case .ledgerAccount:
            headerTitle = String(localized: "title-account-details")
        case .assets:
            headerTitle = String(localized: "title-assets")
        case .rekeyedAccounts:
            headerTitle =
                account.authorization.isRekeyed
                ? String(localized: "ledger-account-detail-can-signed")
                : String(localized: "ledger-account-detail-can-sign")
        }
    }
}
