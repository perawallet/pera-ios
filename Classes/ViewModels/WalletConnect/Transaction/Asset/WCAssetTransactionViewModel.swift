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
//   WCAssetTransactionViewModel.swift

import UIKit

class WCAssetTransactionViewModel {
    private(set) var senderInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var assetInformationViewModel: TransactionAssetViewModel?
    private(set) var receiverInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var balanceInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var amountInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var feeInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var noteInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?

    init(account: Account) {
        setSenderInformationViewModel(from: account)
        setAssetInformationViewModel()
        setReceiverInformationViewModel()
        setRekeyWarningInformationViewModel(from: account)
        setCloseWarningInformationViewModel(from: account)
        setBalanceInformationViewModel()
        setAmountInformationViewModel()
        setFeeInformationViewModel()
        setNoteInformationViewModel()
        setRawTransactionInformationViewModel()
    }

    private func setSenderInformationViewModel(from account: Account) {
        senderInformationViewModel = TitledTransactionAccountNameViewModel(title: "transaction-detail-from".localized, account: account)
    }

    private func setAssetInformationViewModel() {
        assetInformationViewModel = TransactionAssetViewModel(assetDetail: nil, isLastElement: false)
    }

    private func setReceiverInformationViewModel() {
        receiverInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "transaction-detail-to".localized, detail: ""),
            isLastElement: false
        )
    }

    private func setRekeyWarningInformationViewModel(from account: Account) {
        rekeyWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            account: account,
            warning: .rekeyed,
            isLastElement: false
        )
    }

    private func setCloseWarningInformationViewModel(from account: Account) {
        rekeyWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            account: account,
            warning: .closeAsset,
            isLastElement: true
        )
    }

    private func setBalanceInformationViewModel() {
        balanceInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-balance".localized,
            isLastElement: false
        )
    }

    private func setAmountInformationViewModel() {
        amountInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-amount".localized,
            isLastElement: false
        )
    }

    private func setFeeInformationViewModel() {
        feeInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-fee".localized,
            isLastElement: true
        )
    }

    private func setNoteInformationViewModel() {
        noteInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "transaction-detail-note".localized, detail: ""),
            isLastElement: false
        )
    }

    private func setRawTransactionInformationViewModel() {
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(information: .rawTransaction, isLastElement: true)
    }
}
