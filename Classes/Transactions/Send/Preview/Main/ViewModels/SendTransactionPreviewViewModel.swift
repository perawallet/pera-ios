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

final class SendTransactionPreviewViewModel {
    private(set) var opponentType: TransactionDetailViewModel.Opponent?

    func configureReceivedTransaction(
        _ view: NewSendTransactionPreviewView,
        with draft: AlgosTransactionSendDraft
    ) {
        guard let amount = draft.amount else {
            return
        }

        view.amountView.setAmountViewMode(
            .normal(amount: amount, isAlgos: true, fraction: algosFraction)
        )

        setUserView(for: draft, in: view)
        setOpponentView(for: draft, in: view)
        setFee(for: draft, in: view)

        let balance = draft.from.amount.toAlgos - amount - (draft.fee?.toAlgos ?? 0)

        view.balanceView.setAmountViewMode(
            .normal(amount: balance, isAlgos: true, fraction: algosFraction)
        )

        setNote(for: draft, in: view)
    }

    func configureReceivedTransaction(
        _ view: NewSendTransactionPreviewView,
        with draft: AssetTransactionSendDraft
    ) {
        guard let amount = draft.amount else {
            return
        }

        view.amountView.setAmountViewMode(
            .normal(amount: amount, isAlgos: false, fraction: algosFraction)
        )

        setUserView(for: draft, in: view)
        setOpponentView(for: draft, in: view)
        setFee(for: draft, in: view)

        if let assetDetail = draft.assetDetail,
           let balance = draft.from.amount(for: assetDetail) {
            view.balanceView.setAmountViewMode(
                .normal(amount: balance - amount, isAlgos: false, fraction: assetDetail.fractionDecimals)
            )
        }

        setNote(for: draft, in: view)
    }

    private func setUserView(
        for transactionDraft: TransactionSendDraft,
        in view: NewSendTransactionPreviewView
    ) {
        view.userView.setDetail(transactionDraft.from.name ?? transactionDraft.from.address)
    }

    private func setOpponentView(
        for transactionDraft: TransactionSendDraft,
        in view: NewSendTransactionPreviewView
    ) {
        if let contact = transactionDraft.toContact {
            view.opponentView.setDetail(contact.name ?? contact.address)
        } else {
            view.opponentView.setDetail(transactionDraft.toAccount ?? "")
        }
    }

    private func setFee(
        for transactionDraft: TransactionSendDraft,
        in view: NewSendTransactionPreviewView
    ) {
        if let fee = transactionDraft.fee {
            view.feeView.setAmountViewMode(
                .normal(amount: fee.toAlgos, isAlgos: true, fraction: algosFraction)
            )
        }
    }

    private func setNote(
        for transactionDraft: TransactionSendDraft,
        in view: NewSendTransactionPreviewView
    ) {
        if let note = transactionDraft.note {
            view.noteView.setDetail(note)
        }

        view.setNoteViewVisible(!transactionDraft.note.isNilOrEmpty)
    }
}
