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

//   KeyRegTransactionDetailViewModel.swift

import UIKit
import MacaroonUIKit
import pera_wallet_core

final class KeyRegTransactionDetailViewModel: ViewModel {
    private(set) var transactionStatus: TransactionStatus?
    private(set) var userViewTitle: String?
    private(set) var userViewDetail: String?
    private(set) var feeViewMode: TransactionAmountView.Mode?
    private(set) var date: String?
    private(set) var roundViewIsHidden: Bool = false
    private(set) var roundViewDetail: String?
    private(set) var noteViewDetail: String?
    private(set) var noteViewIsHidden: Bool = false
    private(set) var rewardViewIsHidden: Bool = false
    private(set) var transactionIDTitle: String?
    private(set) var transactionID: String?
    private(set) var rewardViewMode: TransactionAmountView.Mode?
    private(set) var voteKeyViewModel: TransactionTextInformationViewModel?
    private(set) var selectionKeyViewModel: TransactionTextInformationViewModel?
    private(set) var stateProofKeyViewModel: TransactionTextInformationViewModel?
    private(set) var voteFirstValidRoundViewModel: TransactionTextInformationViewModel?
    private(set) var voteLastValidRoundViewModel: TransactionTextInformationViewModel?
    private(set) var voteKeyDilutionViewModel: TransactionTextInformationViewModel?
    private(set) var participationStatusViewModel: TransactionTextInformationViewModel?

    init(
        transaction: TransactionItem,
        account: Account
    ) {
        bindTransaction(
            with: transaction,
            for: account
        )
    }
}

extension KeyRegTransactionDetailViewModel {
    private func bindTransaction(
        with transaction: TransactionItem,
        for account: Account
    ) {
        transactionStatus = transaction.status

        bindReward(for: transaction)

        userViewTitle = String(localized: "transaction-detail-from")

        let senderAddress = transaction.sender

        if senderAddress == account.address {
            userViewDetail = account.primaryDisplayName
        } else {
            userViewDetail = senderAddress
        }
        
        let fee: UInt64? = {
            if let tx = transaction as? Transaction { return tx.fee }
            if let tx = transaction as? TransactionV2 { return UInt64(tx.fee ?? .empty) }
            return nil
        }()

        if let fee {
            feeViewMode = .normal(amount: fee.toAlgos)
        }

        bindDate(for: transaction)
        bindRound(for: transaction)
        bindTransactionIDTitle(for: transaction)
        transactionID = {
            if let tx = transaction as? Transaction { return tx.id ?? tx.parentID }
            if let tx = transaction as? TransactionV2 { return tx.id }
            return nil
        }()
        bindNote(for: transaction)
        bindVoteKeyViewModel(from: transaction)
        bindSelectionKeyViewModel(from: transaction)
        bindStateProofKeyViewModel(from: transaction)
        bindVoteFirstValidRoundViewModel(from: transaction)
        bindVoteLastValidRoundViewModel(from: transaction)
        bindVoteKeyDiluationViewModel(from: transaction)
        bindParticipationStatusViewModel(from: transaction)
    }
}

extension KeyRegTransactionDetailViewModel {
    private func bindDate(for transaction: TransactionItem) {
        if transaction.isPending() {
            date = Date().toFormat("MMMM dd, yyyy - HH:mm")
        } else {
            date = transaction.date?.toFormat("MMMM dd, yyyy - HH:mm")
        }
    }

    private func bindRound(for transaction: TransactionItem) {
        if transaction.isPending() {
            roundViewIsHidden = true
        } else {
            let round: UInt64? = {
                if let tx = transaction as? Transaction { return tx.confirmedRound }
                if let tx = transaction as? TransactionV2 { return UInt64(tx.confirmedRound ?? .empty) }
                return nil
            }()
            if let round {
                roundViewDetail = "\(round)"
            }
        }
    }

    private func bindTransactionIDTitle(for transaction: TransactionItem) {
        if  let tx = transaction as? Transaction,
            tx.isInner {
            transactionIDTitle = String(localized: "transaction-detail-parent-id")
            return
        }

        transactionIDTitle = String(localized: "transaction-detail-id")
    }
    
    private func bindNote(for transaction: TransactionItem) {
        if let note = transaction.noteRepresentation {
            noteViewDetail = note
        } else {
            noteViewIsHidden = true
        }
    }

    private func bindReward(for transaction: TransactionItem) {
        if let tx = transaction as? Transaction,
           let rewards = tx.senderRewards,
           rewards > 0 {
            rewardViewMode = .normal(amount: rewards.toAlgos)
        } else {
            rewardViewIsHidden = true
        }
    }

    private func bindVoteKeyViewModel(from transaction: TransactionItem) {
        guard
            let tx = transaction as? Transaction,
            let keyRegTransaction = tx.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let voteKey = keyRegTransaction.voteParticipationKey
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: String(localized: "vote-key-title"),
            detail: voteKey
        )
        self.voteKeyViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func bindSelectionKeyViewModel(from transaction: TransactionItem) {
        guard
            let tx = transaction as? Transaction,
            let keyRegTransaction = tx.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let selectionKey = keyRegTransaction.selectionParticipationKey
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: String(localized: "title-selection-key"),
            detail: selectionKey
        )
        self.selectionKeyViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func bindStateProofKeyViewModel(from transaction: TransactionItem) {
        guard
            let tx = transaction as? Transaction,
            let keyRegTransaction = tx.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let stateProofKey = keyRegTransaction.stateProofKey
        else {
            return
        }

        let titledInformation = TitledInformation(
            title: String(localized: "title-state-proof-key"),
            detail: stateProofKey
        )
        self.stateProofKeyViewModel = TransactionTextInformationViewModel(titledInformation)
    }

    private func bindVoteFirstValidRoundViewModel(from transaction: TransactionItem) {
        guard
            let tx = transaction as? Transaction,
            let keyRegTransaction = tx.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let voteFirstValidRound = keyRegTransaction.voteFirstValid
        else {
            return
        }

        let formatter = Formatter.decimalFormatter()
        let formattedVoteFirstValidRound = formatter.string(from: NSNumber(value: voteFirstValidRound))
        let titledInformation = TitledInformation(
            title: String(localized: "valid-first-round-title"),
            detail: formattedVoteFirstValidRound
        )
        voteFirstValidRoundViewModel = .init(titledInformation)
    }

    private func bindVoteLastValidRoundViewModel(from transaction: TransactionItem) {
        guard
            let tx = transaction as? Transaction,
            let keyRegTransaction = tx.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let voteLastValidRound = keyRegTransaction.voteLastValid
        else {
            return
        }

        let formatter = Formatter.decimalFormatter()
        let formattedVoteLastValidRound = formatter.string(from: NSNumber(value: voteLastValidRound))
        let titledInformation = TitledInformation(
            title: String(localized: "valid-last-round-title"),
            detail: formattedVoteLastValidRound
        )
        voteLastValidRoundViewModel = .init(titledInformation)
    }

    private func bindVoteKeyDiluationViewModel(from transaction: TransactionItem) {
        guard
            let tx = transaction as? Transaction,
            let keyRegTransaction = tx.keyRegTransaction,
            keyRegTransaction.isOnlineKeyRegTransaction,
            let voteKeyDilution = keyRegTransaction.voteKeyDilution
        else {
            return
        }

        let formatter = Formatter.decimalFormatter()
        let formattedVoteKeyDilution = formatter.string(from: NSNumber(value: voteKeyDilution))
        let titledInformation = TitledInformation(
            title: String(localized: "vote-key-dilution-title"),
            detail: formattedVoteKeyDilution
        )
        voteKeyDilutionViewModel = .init(titledInformation)
    }

    private func bindParticipationStatusViewModel(from transaction: TransactionItem) {
        guard
            let tx = transaction as? Transaction,
            let transactionDetail = tx.keyRegTransaction,
              !transactionDetail.isOnlineKeyRegTransaction else {
            return
        }

        let nonParticipation = transactionDetail.nonParticipation
        let participationStatusTitle =
            nonParticipation
            ? String(localized: "not-participating-title")
            : String(localized: "participating-title")
        let titledInformation = TitledInformation(
            title: String(localized: "participation-status-title"),
            detail: participationStatusTitle
        )
        participationStatusViewModel = .init(titledInformation)
    }
}
