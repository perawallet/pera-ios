//
//  AddAssetTransactionDataBuilder.swift

import Foundation

class AddAssetTransactionDataBuilder: TransactionDataBuilder {

    override func composeData() -> Data? {
        return composeAssetAdditionData()
    }

    private func composeAssetAdditionData() -> Data? {
        guard let params = params,
              let assetTransactionDraft = draft as? AssetTransactionSendDraft,
              let assetIndex = assetTransactionDraft.assetIndex else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.draft(draft: draft)))
            return nil
        }

        var transactionError: NSError?
        let draft = AssetAdditionDraft(from: assetTransactionDraft.from, transactionParams: params, assetIndex: assetIndex)

        guard let transactionData = algorandSDK.addAsset(with: draft, error: &transactionError) else {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.sdkError(error: transactionError)))
            return nil
        }

        return transactionData
    }
}
