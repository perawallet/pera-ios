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
    private(set) var fromInformationViewModel: TransactionTextInformationViewModel?
    private(set) var toInformationViewModel: TransactionTextInformationViewModel?
    private(set) var balanceViewModel: TransactionAmountInformationViewModel?
    private(set) var assetInformationViewModel: WCAssetInformationViewModel?
    private(set) var closeInformationViewModel: TransactionTextInformationViewModel?
    private(set) var rekeyInformationViewModel: TransactionTextInformationViewModel?
    private(set) var warningInformationViewModel: WCTransactionWarningViewModel?

    private(set) var amountViewModel: TransactionAmountInformationViewModel?
    private(set) var feeViewModel: TransactionAmountInformationViewModel?
    private(set) var feeWarningInformationViewModel: WCTransactionWarningViewModel?

    private(set) var noteInformationViewModel: TransactionTextInformationViewModel?
    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?


    init(transaction: WCTransaction, senderAccount: Account?, assetDetail: AssetDetail?) {
        setFromInformationViewModel(transaction)
        setToInformationViewModel(transaction)
        setBalanceInformationViewModel(from: senderAccount, and: assetDetail)
        setAssetInformationViewModel(from: senderAccount, and: assetDetail)
        setCloseWarningViewModel(from: transaction, and: assetDetail)
        setRekeyWarningViewModel(from: transaction)

        setAmountInformationViewModel(from: transaction, and: assetDetail)
        setFeeInformationViewModel(from: transaction, and: assetDetail)
        setFeeWarningInformationViewModel(from: transaction)

        setNoteInformationViewModel(from: transaction)
        setRawTransactionInformationViewModel(from: transaction)
    }

    private func setFromInformationViewModel(_ transaction: WCTransaction) {
        guard let fromAddress = transaction.transactionDetail?.sender else {
            return
        }

        let titledInformation = TitledInformation(
            title: "transaction-detail-from".localized,
            detail: fromAddress
        )

        self.fromInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setToInformationViewModel(_ transaction: WCTransaction) {
        guard let toAddress = transaction.transactionDetail?.receiver else {
            return
        }

        let titledInformation = TitledInformation(
            title: "transaction-detail-to".localized,
            detail: toAddress
        )

        self.toInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setBalanceInformationViewModel(from senderAccount: Account?, and assetDetail: AssetDetail?) {
        guard
            let senderAccount = senderAccount,
            let assetDetail = assetDetail,
            let amount = senderAccount.amount(for: assetDetail) else {
                return
        }

        let amountViewModel = TransactionAmountViewModel(
            .normal(
                amount: amount,
                isAlgos: false,
                fraction: assetDetail.fractionDecimals,
                assetSymbol: assetDetail.unitName
            )
        )

        let balanceViewModel = TransactionAmountInformationViewModel(transactionViewModel: amountViewModel)
        balanceViewModel.setTitle("title-account-balance".localized)
        self.balanceViewModel = balanceViewModel
    }

    private func setAssetInformationViewModel(from senderAccount: Account?, and assetDetail: AssetDetail?) {

        assetInformationViewModel = WCAssetInformationViewModel(
            title: "asset-title".localized,
            assetDetail: assetDetail
        )
    }

    private func setCloseWarningViewModel(from transaction: WCTransaction, and assetDetail: AssetDetail?) {
        guard
            let transactionDetail = transaction.transactionDetail,
            let closeAddress = transactionDetail.closeAddress,
            let assetDetail = assetDetail else {
                return
            }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-warning-close-asset-title".localized,
            detail: closeAddress
        )

        self.closeInformationViewModel = TransactionTextInformationViewModel(titledInformation)

        self.warningInformationViewModel = WCTransactionWarningViewModel(warning: .closeAsset(asset: assetDetail))
    }

    private func setRekeyWarningViewModel(from transaction: WCTransaction) {
        guard let rekeyAddress = transaction.transactionDetail?.rekeyAddress else {
            return
        }

        let titledInformation = TitledInformation(
            title: "wallet-connect-transaction-warning-rekey-title".localized,
            detail: rekeyAddress
        )

        self.rekeyInformationViewModel = TransactionTextInformationViewModel(titledInformation)

        self.warningInformationViewModel = WCTransactionWarningViewModel(warning: .rekeyed)
    }

    private func setAmountInformationViewModel(from transaction: WCTransaction, and assetDetail: AssetDetail?) {
        guard
            let assetDetail = assetDetail,
            let amount = transaction.transactionDetail?.amount else {
                return
        }
        let amountValue = Decimal(amount)

        let amountViewModel = TransactionAmountViewModel(
            .normal(
                amount: amountValue,
                isAlgos: false,
                fraction: assetDetail.fractionDecimals,
                assetSymbol: assetDetail.unitName
            )
        )

        let amountInformationViewModel = TransactionAmountInformationViewModel(transactionViewModel: amountViewModel)
        amountInformationViewModel.setTitle("transaction-detail-amount".localized)
        self.amountViewModel = amountInformationViewModel
    }

    private func setFeeInformationViewModel(from transaction: WCTransaction, and assetDetail: AssetDetail?) {

        guard let transactionDetail = transaction.transactionDetail,
              let fee = transactionDetail.fee,
              fee != 0 else {
            return
        }

        let feeViewModel = TransactionAmountViewModel(
            .normal(
                amount: fee.toAlgos,
                isAlgos: true,
                fraction: algosFraction
            )
        )

        let feeInformationViewModel = TransactionAmountInformationViewModel(transactionViewModel: feeViewModel)
        feeInformationViewModel.setTitle("transaction-detail-fee".localized)
        self.feeViewModel = feeInformationViewModel
    }

    private func setFeeWarningInformationViewModel(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail,
              transactionDetail.hasHighFee else {
                  return
        }

        self.feeWarningInformationViewModel = WCTransactionWarningViewModel(warning: .fee)
    }

    private func setNoteInformationViewModel(from transaction: WCTransaction) {
        guard let note = transaction.transactionDetail?.noteRepresentation() else {
            return
        }

        let titledInformation = TitledInformation(
            title: "transaction-detail-note".localized,
            detail: note
        )

        self.noteInformationViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func setRawTransactionInformationViewModel(from transaction: WCTransaction) {
        self.rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(information: .rawTransaction, isLastElement: true)
    }
}
