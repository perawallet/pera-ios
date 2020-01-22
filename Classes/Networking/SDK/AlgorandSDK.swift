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
}

extension AlgorandSDK {
    func sendAlgos(with draft: AlgoTransactionDraft, error: inout NSError?) -> Data? {
        return TransactionMakePaymentTxn(
            draft.from,
            draft.to,
            draft.transactionParams.fee,
            draft.amount,
            draft.transactionParams.lastRound,
            draft.transactionParams.lastRound + 1000, // Need to add 1000 as last round
            nil,
            draft.isMaxTransaction ? draft.to : nil,
            nil,
            draft.transactionParams.genesisHashData,
            &error
        )
    }
}

extension AlgorandSDK {
    func sendAsset(with draft: AssetTransactionsDraft, error: inout NSError?) -> Data? {
        return TransactionMakeAssetTransferTxn(
            draft.from,
            draft.to,
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
            draft.from,
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
            draft.from,
            draft.from, // Receiver address should be same with the sender while removing an asset
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
