//
//  TransactionAPIConnector.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Magpie

class TransactionAPIConnector {

    private var api: AlgorandAPI

    init(api: AlgorandAPI) {
        self.api = api
    }

    func getTransactionParams(then completion: @escaping (TransactionParams?, APIError?) -> Void) {
        api.getTransactionParams { response in
            switch response {
            case let .success(params):
                completion(params, nil)
            case let .failure(error, _):
                completion(nil, error)
            }
        }
    }

    func uploadTransaction(_ signedTransaction: Data, then completion: @escaping (TransactionID?, APIError?) -> Void) {
        api.sendTransaction(with: signedTransaction) { transactionIdResponse in
            switch transactionIdResponse {
            case let .success(transactionId):
                self.api.trackTransaction(with: TransactionTrackDraft(transactionId: transactionId.identifier))
                completion(transactionId, nil)
            case let .failure(error, _):
                completion(nil, error)
            }
        }
    }
}
