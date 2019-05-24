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
    
    enum Formatter {
        static let date: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter
        }()
    }
    
    @discardableResult
    func fetchTransactions(
        between dates: (Date, Date)?,
        for account: Account,
        max: Int = 100,
        completion: APICompletionHandler<TransactionList>? = nil
    ) -> EndpointInteractable? {
        
        var parameters: Params = []
        
        if let betweenDates = dates {
            let from = Formatter.date.string(from: betweenDates.0)
            let to = Formatter.date.string(from: betweenDates.1)
            
            parameters.append(.custom(key: AlgorandParamPairKey.from, value: from))
            parameters.append(.custom(key: AlgorandParamPairKey.to, value: to))
        }
        
        parameters.append(.custom(key: AlgorandParamPairKey.max, value: max))
        
        return send(
            Endpoint<TransactionList>(Path("/v1/account/\(account.address)/transactions"))
                .httpMethod(.get)
                .query(parameters)
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
