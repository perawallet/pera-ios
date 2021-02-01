//
//  TransactionDataBuilder.swift

import Magpie

class TransactionDataBuilder: NSObject, TransactionDataBuildable {

    weak var delegate: TransactionDataBuilderDelegate?

    private(set) var params: TransactionParams?
    private(set) var draft: TransactionSendDraft?

    let algorandSDK = AlgorandSDK()

    init(params: TransactionParams?, draft: TransactionSendDraft?) {
        self.params = params
        self.draft = draft
    }

    func composeData() -> Data? {
        return nil
    }
}

extension TransactionDataBuilder {
    func isValidAddress(_ address: String) -> Bool {
        if !algorandSDK.isValidAddress(address) {
            delegate?.transactionDataBuilder(self, didFailedComposing: .inapp(TransactionError.invalidAddress(address: address)))
            return false
        }
        
        return true
    }
}

protocol TransactionDataBuilderDelegate: class {
    func transactionDataBuilder(_ transactionDataBuilder: TransactionDataBuilder, didFailedComposing error: HIPError<TransactionError>)
}
