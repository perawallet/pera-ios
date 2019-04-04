//
//  API+Transaction.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie
import Crypto

extension API {
    @discardableResult
    func sendTransaction(
        with draft: TransactionDraft,
        then completion: CompletionHandler<TransactionID>? = nil
        ) -> EndpointInteractable? {
        
        var transactionError: NSError?
        
        let transactionData = TransactionMakePaymentTxn(
            draft.from.address,
            draft.to.address,
            draft.transactionParams.fee,
            draft.amount,
            draft.transactionParams.firstRound,
            draft.transactionParams.lastRound,
            nil,
            "",
            "",
            &transactionError)
        
        guard let transaction = transactionData else {
            return nil
        }
        
        var signedTransactionError: NSError?
        
        guard let privateData = UIApplication.shared.appConfiguration?.session.privateData(forAccount: draft.from.address),
            let signedTransactionData = CryptoSignTransaction(privateData, transaction, &signedTransactionError) else {
                return nil
        }
        
        return upload(
            data: signedTransactionData,
            toEndpoint: Endpoint<TransactionID>(Path("/v1/transactions"))
                .httpMethod(.post)
                .handler { uploadResponse in
                    switch uploadResponse {
                    case .success(let transaction):
                        print(transaction.identifier)
                    case .failure(let error):
                        print(error)
                    }
                }
        )
    }
    
    @discardableResult
    func getTransactionParams(completion: CompletionHandler<TransactionParams>? = nil) -> EndpointInteractable? {
        return send(
            Endpoint<TransactionParams>(Path("/v1/transactions/params"))
                .httpMethod(.get)
                .handler { response in
                    completion?(response)
                }
        )
    }
}

extension String: Mappable {
    
}
