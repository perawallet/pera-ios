// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SendKeyRegTransactionItemViewModel.swift

import MacaroonUIKit
import SwiftUI

final class SendKeyRegTransactionItemViewModel: ViewModel, ObservableObject {
    @Published var items: [KeyRegTransactionItem] = []
    
    init(
        _ draft: KeyRegTransactionSendDraft
    ) {
        bindAddress(draft)
        bindFee(draft)
        bindType(draft)
        bindSelectionKey(draft)
        bindVotingKey(draft)
        bindStateProofKey(draft)
        bindKeyDilution(draft)
        bindFirstValid(draft)
        bindLastValid(draft)
        bindNote(draft)
    }
}

extension SendKeyRegTransactionItemViewModel {
    func bindAddress(_ draft: KeyRegTransactionSendDraft) {
        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-address".localized,
            value: draft.from.address,
            hasSeparator: false
        )
        items.append(item)
    }
    
    func bindFee(_ draft: KeyRegTransactionSendDraft) {
        let formatter = CurrencyFormatter()
        formatter.formattingContext = .standalone()
        formatter.currency = AlgoLocalCurrency()
        
        let unformattedFee = draft.fee?.toAlgos ?? Transaction.Constant.minimumFee.toAlgos
        guard let formattedFee = formatter.format(unformattedFee) else { return }
        
        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-fee".localized,
            value: formattedFee,
            hasSeparator: false
        )
        items.append(item)
    }
    
    func bindType(_ draft: KeyRegTransactionSendDraft) {
        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-type".localized,
            value: "keyreg",
            hasSeparator: true
        )
        items.append(item)
    }
    
    func bindSelectionKey(_ draft: KeyRegTransactionSendDraft) {
        guard let selectionKey = draft.selectionKey else { return }

        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-selection".localized,
            value: selectionKey,
            hasSeparator: false
        )
        items.append(item)
    }
    
    func bindVotingKey(_ draft: KeyRegTransactionSendDraft) {
        guard let voteKey = draft.voteKey else { return }
        
        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-voting".localized,
            value: voteKey,
            hasSeparator: false
        )
        items.append(item)
    }
    
    func bindStateProofKey(_ draft: KeyRegTransactionSendDraft) {
        guard let stateProofKey = draft.stateProofKey else { return }
        
        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-state".localized,
            value: stateProofKey,
            hasSeparator: false
        )
        items.append(item)
    }
    
    func bindKeyDilution(_ draft: KeyRegTransactionSendDraft) {
        guard let voteKeyDilution = draft.voteKeyDilution else { return }
        
        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-key".localized,
            value: "\(voteKeyDilution)",
            hasSeparator: true
        )
        items.append(item)
    }
    
    func bindFirstValid(_ draft: KeyRegTransactionSendDraft) {
        guard let firstRound = draft.voteFirst else { return }
        
        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-first".localized,
            value: "\(firstRound)",
            hasSeparator: false
        )
        items.append(item)
    }
    
    func bindLastValid(_ draft: KeyRegTransactionSendDraft) {
        guard let lastRound = draft.voteLast else { return }
        
        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-last".localized,
            value: "\(lastRound)",
            hasSeparator: true
        )
        items.append(item)
    }
    
    func bindNote(_ draft: KeyRegTransactionSendDraft) {
        if let lockedNote = draft.lockedNote {
            let item = KeyRegTransactionItem(
                title: "title-keyreg-txn-xnote".localized,
                value: lockedNote,
                hasSeparator: true
            )
            items.append(item)
            return
        }
        
        if let note = draft.note {
            let item = KeyRegTransactionItem(
                title: "title-keyreg-txn-note".localized,
                value: note,
                hasSeparator: true,
                action: "send-transaction-edit-note-title".localized
            )
            items.append(item)
            return
        }
        
        let item = KeyRegTransactionItem(
            title: "title-keyreg-txn-note".localized,
            value: "",
            hasSeparator: true,
            action: "send-transaction-add-note-title".localized
        )
        items.append(item)
    }
}
