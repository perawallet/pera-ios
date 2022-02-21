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

//
//   WCGroupTransactionAccountInformationViewModel.swift

import Foundation

class WCGroupTransactionAccountInformationViewModel {
    private(set) var accountNameViewModel: AccountNameViewModel?
    private(set) var isAlgos = true
    private(set) var isDisplayingDotSeparator = true
    private(set) var balance: String?
    private(set) var assetName: String?

    init(account: Account?, assetDecoration: AssetDecoration?, isDisplayingAmount: Bool) {
        setAccountNameViewModel(from: account)
        setIsAlgos(from: assetDecoration, and: isDisplayingAmount)
        setBalance(from: account, and: assetDecoration, with: isDisplayingAmount)
        setAssetName(from: assetDecoration, and: isDisplayingAmount)
        setIsDisplayingDotSeparator(from: isDisplayingAmount)
    }

    private func setAccountNameViewModel(from account: Account?) {
        guard let account = account else {
            return
        }

        accountNameViewModel = AccountNameViewModel(account: account)
    }

    private func setIsAlgos(from assetDecoration: AssetDecoration?, and isDisplayingAmount: Bool) {
        if !isDisplayingAmount {
            isAlgos = false
            return
        }

        isAlgos = assetDecoration == nil
    }

    private func setIsDisplayingDotSeparator(from isDisplayingAmount: Bool) {
        isDisplayingDotSeparator = isDisplayingAmount && balance != nil
    }

    private func setBalance(from account: Account?, and assetDecoration: AssetDecoration?, with isDisplayingAmount: Bool) {
        if !isDisplayingAmount {
            return
        }

        guard let account = account, hasValidAmount(of: account, for: assetDecoration) else {
            return
        }

        if let assetDecoration = assetDecoration {
            balance = account.amountDisplayWithFraction(for: assetDecoration)
            return
        }

        balance = account.amount.toAlgos.toAlgosStringForLabel
    }

    private func setAssetName(from assetDecoration: AssetDecoration?, and isDisplayingAmount: Bool) {
        if !isDisplayingAmount {
            return
        }

        if balance == nil {
            return
        }

        if let assetDecoration = assetDecoration {
            assetName = assetDecoration.getDisplayNames().1
        } else {
            assetName = "ALGO"
        }
    }

    private func hasValidAmount(of account: Account, for assetDetail: AssetDecoration?) -> Bool {
        guard let assetDetail = assetDetail else {
            return account.amount > 0
        }

        guard let amount = account.amount(for: assetDetail) else {
            return false
        }
        return !amount.isZero
    }
}
