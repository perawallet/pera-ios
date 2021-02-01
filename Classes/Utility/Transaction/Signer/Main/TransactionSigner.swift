//
//  TransactionSigner.swift

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
