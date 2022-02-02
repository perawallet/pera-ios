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
//   SendTransactionPreviewViewModel.swift


import Foundation
import UIKit
import MacaroonUIKit

final class SendTransactionPreviewViewModel: ViewModel {
    private(set) var amountViewMode: TransactionAmountView.Mode?
    private(set) var userView: TitledTransactionAccountNameViewModel?
    private(set) var opponentView: TitledTransactionAccountNameViewModel?
    private(set) var feeViewMode: TransactionAmountView.Mode?
    private(set) var balanceViewMode: TransactionAmountView.Mode?
    private(set) var noteViewDetail: String?

    init(_ model: TransactionSendDraft, currency: Currency?) {
        if let algoTransactionSendDraft = model as? AlgosTransactionSendDraft {
            bindAlgoTransactionPreview(algoTransactionSendDraft, with: currency)
        } else if let assetTransactionSendDraft = model as? AssetTransactionSendDraft {
            bindAssetTransactionPreview(assetTransactionSendDraft, with: currency)
        }
    }

    private func bindAlgoTransactionPreview(_ draft: AlgosTransactionSendDraft, with currency: Currency?) {
        guard let amount = draft.amount else {
            return
        }

        guard let currency = currency,
              let currencyPriceValue = currency.priceValue else {
            return
        }

        let currencyValue = amount * currencyPriceValue
        let currencyString = currencyValue.toCurrencyStringForLabel(with: currency.symbol)

        amountViewMode = .normal(amount: amount, isAlgos: true, fraction: algosFraction, currency: currencyString)

        setUserView(for: draft)
        setOpponentView(for: draft)
        setFee(for: draft)

        let balance = draft.from.amount.toAlgos

        let balanceCurrencyValue = balance * currencyPriceValue
        let balanceCurrencyString = balanceCurrencyValue.toCurrencyStringForLabel(with: currency.symbol)

        balanceViewMode = .normal(amount: balance, isAlgos: true, fraction: algosFraction, currency: balanceCurrencyString)

        setNote(for: draft)
    }

    private func bindAssetTransactionPreview(_ draft: AssetTransactionSendDraft, with currency: Currency?) {
        guard let amount = draft.amount, let assetDetail = draft.assetDetail else {
            return
        }

        guard let assetUSDValue = assetDetail.usdValue,
              let currency = currency,
              let currencyUSDValue = currency.usdValue else {
            return
        }

        let currencyValue = assetUSDValue * amount * currencyUSDValue
        let currencyString = currencyValue.toCurrencyStringForLabel(with: currency.symbol)
        
        amountViewMode = .normal(amount: amount, isAlgos: false, fraction: algosFraction, assetSymbol: assetDetail.name, currency: currencyString)

        setUserView(for: draft)
        setOpponentView(for: draft)
        setFee(for: draft)

        if let balance = draft.from.amount(for: assetDetail) {


            let balanceCurrencyValue = assetUSDValue * balance * currencyUSDValue
            let balanceCurrencyString = balanceCurrencyValue.toCurrencyStringForLabel(with: currency.symbol)

            balanceViewMode = .normal(amount: balance, isAlgos: false, fraction: algosFraction, assetSymbol: assetDetail.name, currency: balanceCurrencyString)
        }

        setNote(for: draft)
    }

    private func setUserView(
        for draft: TransactionSendDraft
    ) {
        userView = TitledTransactionAccountNameViewModel(
            title: "title-account".localized,
            account: draft.from,
            hasImage: true
        )
    }


    private func setOpponentView(
        for draft: TransactionSendDraft
    ) {
        let title = "transaction-detail-to".localized

        if let contact = draft.toContact {
            opponentView = TitledTransactionAccountNameViewModel(
                title: title,
                contact: contact,
                hasImage: true
            )
        } else {
            guard let toAccount = draft.toAccount else {
                return
            }

            opponentView = TitledTransactionAccountNameViewModel(
                title: title,
                account: toAccount,
                hasImage: toAccount.isCreated
            )
        }
    }

    private func setFee(
        for draft: TransactionSendDraft
    ) {
        if let fee = draft.fee {
            feeViewMode = .normal(amount: fee.toAlgos, isAlgos: true, fraction: algosFraction)
        }
    }

    private func setNote(
        for draft: TransactionSendDraft
    ) {
        if let note = draft.note {
            noteViewDetail = note
        }
    }
}
