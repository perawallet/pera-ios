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

final class SendTransactionPreviewViewModel: PairedViewModel {
    private(set) var amountViewMode: TransactionAmountView.Mode?
    private(set) var userViewDetail: String?
    private(set) var opponentViewAddress: String?
    private(set) var feeViewMode: TransactionAmountView.Mode?
    private(set) var balanceViewMode: TransactionAmountView.Mode?
    private(set) var noteViewDetail: String?

    init(_ model: TransactionSendDraft) {
        if let algoTransactionSendDraft = model as? AlgosTransactionSendDraft {
            bindAlgoTransactionPreview(algoTransactionSendDraft)
        } else if let assetTransactionSendDraft = model as? AssetTransactionSendDraft {
            bindAssetTransactionPreview(assetTransactionSendDraft)
        }
    }

    private func bindAlgoTransactionPreview(_ draft: AlgosTransactionSendDraft) {
        guard let amount = draft.amount else {
            return
        }

        amountViewMode = .normal(amount: amount, isAlgos: true, fraction: algosFraction)

        setUserView(for: draft)
        setOpponentView(for: draft)
        setFee(for: draft)

        let balance = draft.from.amount.toAlgos - amount - (draft.fee?.toAlgos ?? 0)

        balanceViewMode = .normal(amount: balance, isAlgos: true, fraction: algosFraction)

        setNote(for: draft)
    }

    private func bindAssetTransactionPreview(_ draft: AssetTransactionSendDraft) {
        guard let amount = draft.amount, let assetDetail = draft.assetDetail else {
            return
        }

        amountViewMode = .normal(amount: amount, isAlgos: false, fraction: algosFraction, assetSymbol: assetDetail.assetName)

        setUserView(for: draft)
        setOpponentView(for: draft)
        setFee(for: draft)

        if let balance = draft.from.amount(for: assetDetail) {
            balanceViewMode = .normal(amount: balance - amount, isAlgos: false, fraction: algosFraction, assetSymbol: assetDetail.assetName)
        }

        setNote(for: draft)
    }

    private func setUserView(
        for draft: TransactionSendDraft
    ) {
        userViewDetail = draft.from.name ?? draft.from.address
    }


    private func setOpponentView(
        for draft: TransactionSendDraft
    ) {
        if let contact = draft.toContact {
            opponentViewAddress = contact.name ?? contact.address
        } else {
            opponentViewAddress = draft.toAccount
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
