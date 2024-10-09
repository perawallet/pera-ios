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

//   OptInAndSendTransactionDataBuilder.swift

import Foundation

final class OptInAndSendTransactionDataBuilder: TransactionDataBuildable {
    var eventHandler: ((TransactionDataBuildableEvent) -> Void)?

    private let algorandSDK = AlgorandSDK()
    
    let sharedDataController: SharedDataController
    let params: TransactionParams
    let draft: TransactionSendDraft

    init(
        sharedDataController: SharedDataController,
        params: TransactionParams,
        draft: TransactionSendDraft
    ) {
        self.sharedDataController = sharedDataController
        self.params = params
        self.draft = draft
    }
    
    func composeData() -> [TransactionDataItem]? {
        return composeOptInAndSendTransaction()
    }
}

private extension OptInAndSendTransactionDataBuilder {
    func composeOptInAndSendTransaction() -> [TransactionDataItem]? {
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

        let sender = assetTransactionDraft.from
        let receiverAddress: String

        if let account = assetTransactionDraft.toAccount {
            receiverAddress = account.address.trimmed()
        } else if let contact = assetTransactionDraft.toContact,
                  let contactAddress = contact.address {
            receiverAddress = contactAddress.trimmed()
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

        if !isValidAddress(receiverAddress) {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.invalidAddress(address: receiverAddress)
                    )
                )
            )
            return nil
        }
        
        guard let receiverAccount = sharedDataController.accountCollection[receiverAddress]?.value else {
            eventHandler?(
                .didFailedComposing(
                    error: .inapp(
                        TransactionError.invalidAddress(address: receiverAddress)
                    )
                )
            )
            return nil
        }

        var transactionError: NSError?
        
        let note = assetTransactionDraft.lockedNote ?? assetTransactionDraft.note
        
        let draft = AssetOptInAndSendTransactionDraft(
            from: sender,
            toAccount: receiverAddress,
            transactionParams: params,
            amount: amountDecimalValue.toFraction(of: assetTransactionDraft.assetDecimalFraction),
            senderAlgoBalance: sender.algo.amount,
            senderMinBalance: sender.calculateMinBalance(),
            receiverAlgoBalance: receiverAccount.algo.amount,
            receiverMinBalance: receiverAccount.calculateMinBalance(),
            assetIndex: assetIndex,
            note: note?.data(using: .utf8)
        )

        guard let transactionData = algorandSDK.composeOptInAndSendAssetTxn(
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
        
        var txnItems: [TransactionDataItem] = []
        
        transactionData.forEach { item in
            guard let data = item.data else { return }
            txnItems.append(
                TransactionDataItem(
                    sender: item.signer,
                    transaction: data
                )
            )
        }

        return txnItems
    }
}
