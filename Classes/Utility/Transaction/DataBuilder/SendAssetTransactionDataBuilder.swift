//
//  SendAssetTransactionDataBuilder.swift

import Foundation

class SendAssetTransactionDataBuilder: TransactionDataBuilder {

    override func composeData() -> Data? {
        return composeAssetTransactionData()
    }

    private func composeAssetTransactionData() -> Data? {
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
        let draft = AssetTransactionDraft(
            from: assetTransactionDraft.from,
            toAccount: toAddress.trimmed,
            transactionParams: params,
            amount: amountDoubleValue.toFraction(of: assetTransactionDraft.assetDecimalFraction),
            assetIndex: assetIndex,
            note: assetTransactionDraft.note?.data(using: .utf8)
        )

        guard let transactionData = algorandSDK.sendAsset(with: draft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }
}
