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

//
//  AssetTransactionDataBuilder.swift

import Foundation

final class AssetTransactionDataBuilder: TransactionDataBuildable {
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
        return composeAssetTransactionData()
    }
}

private extension AssetTransactionDataBuilder {
    func composeAssetTransactionData() -> [TransactionDataItem]? {
        guard let assetTransactionDraft = draft as? AssetTransactionSendDraft,
              let assetIndex = assetTransactionDraft.assetIndex,
              let amountDecimalValue = assetTransactionDraft.amount else {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.other
                    )
                )
            )
            return nil
        }


        let address: String

        if let account = assetTransactionDraft.toAccount {
            address = account.address.trimmed()
        } else if let contact = assetTransactionDraft.toContact, let contactAddress = contact.address {
            address = contactAddress.trimmed()
        } else {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.other
                    )
                )
            )
            return nil
        }

        if !isValidAddress(address) {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.invalidAddress(address: address)
                    )
                )
            )
            return nil
        }

        var transactionError: NSError?
        
        let note = assetTransactionDraft.lockedNote ?? assetTransactionDraft.note
        
        let draft = AssetTransactionDraft(
            from: assetTransactionDraft.from,
            toAccount: address,
            transactionParams: params,
            amount: amountDecimalValue.toFraction(of: assetTransactionDraft.assetDecimalFraction),
            assetIndex: assetIndex,
            note: note?.data(using: .utf8),
            closeTo: assetTransactionDraft.assetCreator
        )

        guard let transactionData = algorandSDK.sendAsset(
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
                sender: assetTransactionDraft.from.address,
                transaction: transactionData
            )
        ]
    }
}
