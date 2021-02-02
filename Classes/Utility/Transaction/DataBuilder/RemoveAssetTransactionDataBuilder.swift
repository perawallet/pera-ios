//
//  RemoveAssetTransactionDataBuilder.swift

import Foundation

class RemoveAssetTransactionDataBuilder: TransactionDataBuilder {

    override func composeData() -> Data? {
        return composeAssetRemovalData()
    }

    private func composeAssetRemovalData() -> Data? {
        guard let params = params,
              let assetTransactionDraft = draft as? AssetTransactionSendDraft,
              let assetIndex = assetTransactionDraft.assetIndex,
              let amountDoubleValue = assetTransactionDraft.amount,
              let toAddress = assetTransactionDraft.toAccount else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.other))
            return nil
        }

        if !isValidAddress(toAddress.trimmed) {
            return nil
        }

        var transactionError: NSError?
        let draft = AssetRemovalDraft(
            from: assetTransactionDraft.from,
            transactionParams: params,
            amount: Int64(amountDoubleValue),
            assetCreatorAddress: assetTransactionDraft.assetCreator,
            assetIndex: assetIndex
        )

        guard let transactionData = algorandSDK.removeAsset(with: draft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }
}
