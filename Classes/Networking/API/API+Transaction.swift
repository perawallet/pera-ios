//
//  API+Transaction.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    
    @discardableResult
    func fetchTransactions(
        between rounds: (Int64, Int64),
        for account: Account,
        completion: APICompletionHandler<TransactionList>? = nil
    ) -> EndpointInteractable? {
        
        return send(
            Endpoint<TransactionList>(Path("/v1/account/\(account.address)/transactions"))
                .httpMethod(.get)
                .query([
                    .custom(key: AlgorandParamPairKey.firstRound, value: rounds.0),
                    .custom(key: AlgorandParamPairKey.lastRound, value: rounds.1)
                ])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchTransactionDetail(
        for account: Account,
        with id: TransactionID,
        completion: APICompletionHandler<Transaction>? = nil
    ) -> EndpointInteractable? {
        
        return send(
            Endpoint<Transaction>(Path("/v1/account/\(account.address)/transaction/\(id.identifier)"))
                .httpMethod(.get)
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func sendTransaction(
        with transactionData: Data,
        then completion: APICompletionHandler<TransactionID>? = nil
    ) -> EndpointInteractable? {
        
        return upload(
            data: transactionData,
            toEndpoint: Endpoint<TransactionID>(Path("/v1/transactions"))
                .httpMethod(.post)
                .handler { uploadResponse in
                    
                    switch uploadResponse {
                    case .success:
                        break
                    case .failure:
                        break
                    }
                    
                    completion?(uploadResponse)
                }
        )
    }
    
    @discardableResult
    func getTransactionParams(completion: APICompletionHandler<TransactionParams>? = nil) -> EndpointInteractable? {
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
