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

//   KeyRegTransactionDataBuilder.swift

import Foundation

final class KeyRegTransactionDataBuilder: TransactionDataBuildable {
    var eventHandler: ((TransactionDataBuildableEvent) -> Void)?

    private let algorandSDK = AlgorandSDK()
    
    let params: TransactionParams
    let draft: TransactionSendDraft

    init(
        params: TransactionParams,
        draft: TransactionSendDraft
    ) {
        self.params = params
        self.draft = draft
    }
    
    func composeData() -> [TransactionDataItem]? {
        return composeKeyRegTransactionData()
    }
}

private extension KeyRegTransactionDataBuilder {
    func composeKeyRegTransactionData() -> [TransactionDataItem]? {
        guard let keyRegTransactionDraft = draft as? KeyRegTransactionSendDraft else {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.other
                    )
                )
            )
            return nil
        }

        var transactionError: NSError?
        
        let note = keyRegTransactionDraft.lockedNote ?? keyRegTransactionDraft.note
        
        var fee: Int64?
        if let feeValueFromDraft = keyRegTransactionDraft.fee {
            fee = Int64(feeValueFromDraft)
        }
        
        var draft: KeyRegTransactionDraft
        
        if isOnlineKeyRegTxn() {
            draft = KeyRegTransactionDraft(
                from: keyRegTransactionDraft.from,
                note: note?.data(using: .utf8),
                transactionParams: params,
                voteKey: keyRegTransactionDraft.voteKey ?? "",
                selectionKey: keyRegTransactionDraft.selectionKey ?? "",
                stateProofKey: keyRegTransactionDraft.stateProofKey ?? "",
                voteFirst: Int64(keyRegTransactionDraft.voteFirst ?? 0),
                voteLast: Int64(keyRegTransactionDraft.voteLast ?? 0),
                voteKeyDilution: Int64(keyRegTransactionDraft.voteKeyDilution ?? 0),
                fee: fee
            )
        } else {
            draft = KeyRegTransactionDraft(
                from: keyRegTransactionDraft.from,
                note: note?.data(using: .utf8),
                transactionParams: params,
                voteKey: nil,
                selectionKey: nil,
                stateProofKey: nil,
                voteFirst: 0,
                voteLast: 0,
                voteKeyDilution: 0,
                fee: nil
            )
        }
        
        guard let transactionData = algorandSDK.sendKeyRegTransaction(
            with: draft,
            error: &transactionError
        ) else {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.sdkError(error: transactionError)
                    )
                )
            )
            return nil
        }

        return  [
            TransactionDataItem(
                sender: keyRegTransactionDraft.from.address,
                transaction: transactionData
            )
        ]
    }
    
    private func isOnlineKeyRegTxn() -> Bool {
        guard let keyRegTransactionDraft = draft as? KeyRegTransactionSendDraft else {
            return false
        }
        
        return !keyRegTransactionDraft.voteKey.isNilOrEmpty &&
            !keyRegTransactionDraft.selectionKey.isNilOrEmpty &&
            (keyRegTransactionDraft.voteFirst != nil) &&
            (keyRegTransactionDraft.voteLast != nil) &&
            (keyRegTransactionDraft.voteKeyDilution != nil)
    }
}
