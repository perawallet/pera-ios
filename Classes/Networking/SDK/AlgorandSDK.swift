//
//  AlgorandSDK.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Crypto

class AlgorandSDK {
    func generatePrivateKey() -> Data? {
        return CryptoGenerateSK()
    }
    
    func sign(_ privateData: Data, with data: Data, error: inout NSError?) -> Data? {
        return CryptoSignTransaction(privateData, data, &error)
    }
}

extension AlgorandSDK {
    func mnemonicFrom(_ privateKey: Data, error: inout NSError?) -> String {
        return MnemonicFromPrivateKey(privateKey, &error)
    }
    
    func privateKeyFrom(_ mnemonic: String, error: inout NSError?) -> Data? {
        return MnemonicToPrivateKey(mnemonic, &error)
    }
    
    func addressFrom(_ privateKey: Data, error: inout NSError?) -> String? {
        return CryptoGenerateAddressFromSK(privateKey, &error)
    }
    
    func addressFrom(_ publicKey: Data, error: inout NSError?) -> String {
        return CryptoGenerateAddressFromPublicKey(publicKey, &error)
    }
}

extension AlgorandSDK {
    func sendAlgos(with draft: AlgosTransactionDraft, error: inout NSError?) -> Data? {
        let toAddress = draft.toAccount.trimmingCharacters(in: .whitespacesAndNewlines)
        return TransactionMakePaymentTxn(
            getTrimmedAddress(from: draft.from),
            toAddress,
            draft.transactionParams.fee,
            draft.amount,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + 1000, // Need to add 1000 as last round
            nil,
            draft.isMaxTransaction ? toAddress : nil,
            nil,
            draft.transactionParams.genesisHashData,
            &error
        )
    }
}

extension AlgorandSDK {
    func sendAsset(with draft: AssetTransactionDraft, error: inout NSError?) -> Data? {
        return TransactionMakeAssetTransferTxn(
            getTrimmedAddress(from: draft.from),
            draft.toAccount.trimmingCharacters(in: .whitespacesAndNewlines),
            "", // closing address should be empty for asset transaction
            draft.amount,
            draft.transactionParams.fee,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + 1000, // Need to add 1000 as last round
            nil,
            nil,
            draft.transactionParams.genesisHashData?.base64EncodedString(),
            draft.assetIndex,
            &error
        )
    }
    
    func addAsset(with draft: AssetAdditionDraft, error: inout NSError?) -> Data? {
        return TransactionMakeAssetAcceptanceTxn(
            getTrimmedAddress(from: draft.from),
            draft.transactionParams.fee,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + 1000, // Need to add 1000 as last round
            nil,
            nil,
            draft.transactionParams.genesisHashData?.base64EncodedString(),
            draft.assetIndex,
            &error
        )
    }
    
    func removeAsset(with draft: AssetRemovalDraft, error: inout NSError?) -> Data? {
        return TransactionMakeAssetTransferTxn(
            getTrimmedAddress(from: draft.from),
            getTrimmedAddress(from: draft.from), // Receiver address should be same with the sender while removing an asset
            draft.assetCreatorAddress, //
            draft.amount,
            draft.transactionParams.fee,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + 1000, // Need to add 1000 as last round
            nil,
            nil,
            draft.transactionParams.genesisHashData?.base64EncodedString(),
            draft.assetIndex,
            &error
        )
    }
}

extension AlgorandSDK {
    func isValidAddress(_ address: String) -> Bool {
        return UtilsIsValidAddress(address)
    }
}

extension AlgorandSDK {
    private func getTrimmedAddress(from account: Account) -> String {
        return account.address.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
