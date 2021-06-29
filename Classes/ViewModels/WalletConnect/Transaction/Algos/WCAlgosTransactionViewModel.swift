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
//   WCAlgosTransactionViewModel.swift

import UIKit

class WCAlgosTransactionViewModel {
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

    init(transactionParams: WCTransactionParams, senderAccount: Account) {
        setSenderInformationViewModel(from: senderAccount)
        setAssetInformationViewModel()
        setReceiverInformationViewModel(from: transactionParams)
        setCloseWarningInformationViewModel(from: transactionParams)
        setRekeyWarningInformationViewModel(from: transactionParams)
        setBalanceInformationViewModel(from: senderAccount)
        setAmountInformationViewModel(from: transactionParams)
        setFeeInformationViewModel(from: transactionParams)
        setNoteInformationViewModel(from: transactionParams)
        setRawTransactionInformationViewModel(from: transactionParams)
    }

    private func setSenderInformationViewModel(from senderAccount: Account) {
        senderInformationViewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-from".localized,
            account: senderAccount
        )
    }

    private func setAssetInformationViewModel() {
        assetInformationViewModel = TransactionAssetViewModel(assetDetail: nil, isLastElement: false)
    }

    private func setReceiverInformationViewModel(from transactionParam: WCTransactionParams) {
        guard let transaction = transactionParam.transaction,
              let receiverAddress = transaction.receiver else {
            return
        }

        receiverInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "transaction-detail-to".localized, detail: receiverAddress.shortAddressDisplay()),
            isLastElement: !transaction.isRekeyTransaction && !transaction.isCloseTransaction
        )
    }

    private func setCloseWarningInformationViewModel(from transactionParam: WCTransactionParams) {
        guard let transaction = transactionParam.transaction,
              let closeAddress = transaction.closeAddress else {
            return
        }

        closeWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            address: closeAddress,
            warning: .closeAlgos,
            isLastElement: !transaction.isRekeyTransaction
        )
    }

    private func setRekeyWarningInformationViewModel(from transactionParam: WCTransactionParams) {
        guard let rekeyAddress = transactionParam.transaction?.rekeyAddress else {
            return
        }

        rekeyWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            address: rekeyAddress,
            warning: .rekeyed,
            isLastElement: true
        )
    }

    private func setBalanceInformationViewModel(from senderAccount: Account) {
        balanceInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-balance".localized,
            mode: .balance(value: Int64(senderAccount.amount)),
            isLastElement: false
        )
    }

    private func setAmountInformationViewModel(from transactionParams: WCTransactionParams) {
        guard let amount = transactionParams.transaction?.amount else {
            return
        }

        amountInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-amount".localized,
            mode: .amount(value: amount),
            isLastElement: false
        )
    }

    private func setFeeInformationViewModel(from transactionParams: WCTransactionParams) {
        guard let fee = transactionParams.transaction?.fee else {
            return
        }

        feeInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-fee".localized,
            mode: .fee(value: fee),
            isLastElement: true
        )
    }

    private func setNoteInformationViewModel(from transactionParams: WCTransactionParams) {
        guard let note = transactionParams.transaction?.noteRepresentation() else {
            return
        }

        noteInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "transaction-detail-note".localized, detail: note),
            isLastElement: false
        )
    }

    private func setRawTransactionInformationViewModel(from transactionParams: WCTransactionParams) {
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(information: .rawTransaction, isLastElement: true)
    }
}
