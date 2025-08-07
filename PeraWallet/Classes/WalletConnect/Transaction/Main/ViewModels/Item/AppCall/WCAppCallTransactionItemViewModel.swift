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
//   WCAppCallTransactionItemViewModel.swift

import Foundation

class WCAppCallTransactionItemViewModel {
    private(set) var hasWarning = false
    private(set) var title: String?
    private(set) var accountInformationViewModel: WCGroupTransactionAccountInformationViewModel?

    init(
        transaction: WCTransaction,
        account: Account?,
        currencyFormatter: CurrencyFormatter
    ) {
        setHasWarning(from: transaction, and: account)
        setTitle(from: transaction)
        setAccountInformationViewModel(
            from: account,
            currencyFormatter: currencyFormatter
        )
    }

    private func setHasWarning(from transaction: WCTransaction, and account: Account?) {
        guard let transactionDetail = transaction.transactionDetail, account != nil else {
            return
        }

        hasWarning = transactionDetail.hasRekeyOrCloseAddress
    }

    private func setTitle(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              let appCallId = transactionDetail.appCallId else {
            return
        }

        if transactionDetail.isAppCreateTransaction {
            title = String(localized: "wallet-connect-transaction-title-app-creation")
            return
        }

        guard let appCallOnComplete = transaction.transactionDetail?.appCallOnComplete else {
            title = String(format: String(localized: "wallet-connect-transaction-group-app-call-title"), appCallId)
            return
        }

        switch appCallOnComplete {
        case .close:
            title = String(format: String(localized: "wallet-connect-transaction-group-app-close-title"), appCallId)
        case .optIn:
            title = String(format: String(localized: "wallet-connect-transaction-group-app-opt-in-title"), appCallId)
        case .update:
            title = String(format: String(localized: "wallet-connect-transaction-group-app-update-title"), appCallId)
        case .delete:
            title = String(format: String(localized: "wallet-connect-transaction-group-app-delete-title"), appCallId)
        default:
            title = String(format: String(localized: "wallet-connect-transaction-group-app-call-title"), appCallId)
        }
    }

    private func setAccountInformationViewModel(
        from account: Account?,
        currencyFormatter: CurrencyFormatter
    ) {
        accountInformationViewModel = WCGroupTransactionAccountInformationViewModel(
            account: account,
            asset: nil,
            isDisplayingAmount: false,
            currencyFormatter: currencyFormatter
        )
    }
}
