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

    init(transactionParams: WCTransactionParams, senderAccount: Account, assetDetail: AssetDetail?) {
        setSenderInformationViewModel(from: senderAccount)
        setAssetInformationViewModel(from: assetDetail)
        setReceiverInformationViewModel(from: transactionParams)
        setCloseWarningInformationViewModel(from: transactionParams)
        setRekeyWarningInformationViewModel(from: transactionParams)
        setBalanceInformationViewModel(from: senderAccount, and: assetDetail)
        setAmountInformationViewModel(from: transactionParams, and: assetDetail)
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

    private func setAssetInformationViewModel(from assetDetail: AssetDetail?) {
        guard let assetDetail = assetDetail else {
            return
        }

        assetInformationViewModel = TransactionAssetViewModel(assetDetail: assetDetail, isLastElement: false)
    }

    private func setReceiverInformationViewModel(from transactionParam: WCTransactionParams) {
        guard let transaction = transactionParam.transaction,
              let receiverAddress = transaction.receiver else {
            return
        }

        receiverInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "transaction-detail-to".localized, detail: receiverAddress),
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
            warning: .closeAsset,
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

    private func setBalanceInformationViewModel(from senderAccount: Account, and assetDetail: AssetDetail?) {
        guard let assetDetail = assetDetail,
              let amount = senderAccount.amountWithoutFraction(for: assetDetail) else {
            return
        }

        balanceInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-balance".localized,
            mode: .balance(value: amount, isAlgos: false, fraction: assetDetail.fractionDecimals),
            isLastElement: false
        )
    }

    private func setAmountInformationViewModel(from transactionParams: WCTransactionParams, and assetDetail: AssetDetail?) {
        guard let assetDetail = assetDetail,
              let amount = transactionParams.transaction?.amount else {
            return
        }

        amountInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-amount".localized,
            mode: .amount(value: amount, isAlgos: false, fraction: assetDetail.fractionDecimals),
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
