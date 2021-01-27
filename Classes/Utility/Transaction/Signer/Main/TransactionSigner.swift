//
//  TransactionSigner.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Magpie

class TransactionSigner: NSObject, TransactionSignable {

    weak var delegate: TransactionSignerDelegate?

    let algorandSDK = AlgorandSDK()

    func sign(_ data: Data?, with privateData: Data?) -> Data? {
        return nil
    }
}

protocol TransactionSignerDelegate: class {
    func transactionSigner(_ transactionSigner: TransactionSigner, didFailedSigning error: HIPError<TransactionError>)
}
