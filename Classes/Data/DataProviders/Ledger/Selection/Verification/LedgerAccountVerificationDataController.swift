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
//   LedgerAccountVerificationDataController.swift

import UIKit

class LedgerAccountVerificationDataController {

    private let selectedAccounts: [Account]
    private(set) var verificationAccounts: [Account] = []
    private var verifiedAccounts: [Account] = []

    init(accounts: [Account]) {
        self.selectedAccounts = accounts
        composeVerificationAccounts()
    }
}

extension LedgerAccountVerificationDataController {
    private func composeVerificationAccounts() {
        selectedAccounts.forEach { selectedAccount in
            // Do not display rekeyed accounts if it's auth account is already in the account list
            if selectedAccount.isRekeyed() {
                addSelectedRekeyedAccountIfNeeded(selectedAccount)
                return
            }

            addSelectedAccountIfNeeded(selectedAccount)
        }
    }

    private func addSelectedRekeyedAccountIfNeeded(_ selectedAccount: Account) {
        if !selectedAccounts.contains(where: { account -> Bool in
            account.address == selectedAccount.authAddress
        }) {
            verificationAccounts.append(selectedAccount)
        }
    }

    private func addSelectedAccountIfNeeded(_ selectedAccount: Account) {
        if !verificationAccounts.contains(selectedAccount) {
            verificationAccounts.append(selectedAccount)
        }
    }
}

extension LedgerAccountVerificationDataController {
    func isLastAccount(_ account: Account?) -> Bool {
        return verificationAccounts.last == account
    }

    func nextIndexForVerification(from address: String) -> Int? {
        guard let addressIndex = verificationAccounts.map({ $0.address }).firstIndex(of: address) else {
            return nil
        }

        return addressIndex + 1
    }

    func addVerifiedAccount(_ address: String) {
        let verificationAccount = verificationAccounts.first { $0.address == address }
        let rekeyedAccounts = selectedAccounts.filter { $0.authAddress == address }

        if let account = verificationAccount {
            verifiedAccounts.append(account)
            verifiedAccounts.append(contentsOf: rekeyedAccounts)
        }
    }

    func getVerifiedAccounts() -> [Account] {
        return verifiedAccounts
    }
}
