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
        with draft: SendTransactionDraft
    ) {
        view.amountView.setTitle("transaction-detail-amount".localized)
        view.amountView.setAmountViewMode(.normal(amount: draft.amount!, isAlgos: true, fraction: 2))

        view.userView.setTitle("title-account".localized)
        view.userView.setDetail(draft.from.name ?? draft.from.address)

        view.opponentView.setTitle("transaction-detail-to".localized)
        if let contact = draft.toContact {
            view.opponentView.setContact(contact)
        } else {
            view.opponentView.setName(draft.toAccount ?? "")
        }
    }


    func setOpponent(for transaction: Transaction, with address: String, in view: TransactionDetailView) {
        if let contact = transaction.contact {
            opponentType = .contact(address: address)
            view.opponentView.setContact(contact)
        } else if let localAccount = UIApplication.shared.appConfiguration?.session.accountInformation(from: address) {
            opponentType = .localAccount(address: address)
            view.opponentView.setName(localAccount.name)
            view.opponentView.removeContactImage()
        } else {
            opponentType = .address(address: address)
            view.opponentView.setName(address)
            view.opponentView.removeContactImage()
        }
    }

    private func setNote(for transaction: Transaction, in view: NewSendTransactionPreviewView) {
        if let note = transaction.noteRepresentation() {
            view.noteView.setDetail(note)
        } else {
            view.noteView.isHidden = true
        }
    }
}
