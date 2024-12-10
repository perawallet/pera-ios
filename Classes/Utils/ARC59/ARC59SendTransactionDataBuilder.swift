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

//   ARC59SendTransactionDataBuilder.swift

import Foundation

final class ARC59SendTransactionDataBuilder: NSObject {
    typealias EventHandler = (ARC59SendTransactionDataBuilderEvent) -> Void
    var eventHandler: EventHandler?

    private(set) var params: TransactionParams?
    private(set) var draft: TransactionSendDraft?

    let algorandSDK = AlgorandSDK()

    init(
        params: TransactionParams?,
        draft: TransactionSendDraft?
    ) {
        self.params = params
        self.draft = draft
    }
}

extension ARC59SendTransactionDataBuilder {
    func composeSendTransactionData() -> [Data]? {
        guard let params = params,
              let assetTransactionDraft = draft as? AssetTransactionARC59SendDraft,
              let assetIndex = assetTransactionDraft.assetIndex,
              let amountDecimalValue = assetTransactionDraft.amount else {
            eventHandler?(.didFailedComposing(error: .inapp(TransactionError.other)))
            return nil
        }

        let address: String

        if let account = assetTransactionDraft.toAccount {
            address = account.address.trimmed()
        } else if let contact = assetTransactionDraft.toContact,
                  let contactAddress = contact.address {
            address = contactAddress.trimmed()
        } else {
            eventHandler?(.didFailedComposing(error: .inapp(TransactionError.other)))
            return nil
        }

        if !address.isValidatedAddress {
            eventHandler?(.didFailedComposing(error: .inapp(TransactionError.invalidAddress(address: address))))
            return nil
        }

        var transactionError: NSError?
        
        let draft = ARC59SendAssetTransactionDraft(
            from: assetTransactionDraft.from,
            transactionParams: params,
            receiver: address,
            appAddress: assetTransactionDraft.appAddress,
            inboxAccount: assetTransactionDraft.inboxAccount,
            amount: amountDecimalValue.toFraction(of: assetTransactionDraft.assetDecimalFraction),
            minBalance: assetTransactionDraft.minBalance,
            innerTransactionCount: assetTransactionDraft.innerTransactionCount,
            appID: assetTransactionDraft.appID,
            assetID: assetIndex,
            extraAlgoAmount: assetTransactionDraft.extraAlgoAmount,
            isOptedInToProtocol: assetTransactionDraft.isOptedInToProtocol
        )

        guard let transactionData = algorandSDK.composeArc59SendAssetTxn(with: draft, error: &transactionError) else {
            eventHandler?(.didFailedComposing(error: .inapp(TransactionError.sdkError(error: transactionError))))
            return nil
        }

        return transactionData
    }
}

enum ARC59SendTransactionDataBuilderEvent {
    case didFailedComposing(error: HIPTransactionError)
}
