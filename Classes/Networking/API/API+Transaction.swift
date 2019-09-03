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
        between dates: (Date, Date)?,
        for account: Account,
        max: Int = 100,
        then handler: @escaping Endpoint.DefaultResultHandler<TransactionList>
    ) -> EndpointOperatable {
        var from: String?
        var to: String?
        
        if let betweenDates = dates,
            let dayAfter = betweenDates.1.dayAfter {
            from = Formatter.date.string(from: betweenDates.0)
            to = Formatter.date.string(from: dayAfter)
        }
        
        let query = TransactionsQuery(max: max, from: from, to: to)
        
        return Endpoint(path: Path("/v1/account/\(account.address)/transactions"))
            .httpMethod(.get)
            .httpHeaders(algorandAuthenticatedHeaders())
            .query(query)
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchTransactionDetail(
        for account: Account,
        with id: TransactionID,
        then handler: @escaping Endpoint.DefaultResultHandler<Transaction>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v1/account/\(account.address)/transaction/\(id.identifier)"))
            .httpMethod(.get)
            .httpHeaders(algorandAuthenticatedHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func sendTransaction(
        with transactionData: Data,
        then handler: @escaping Endpoint.DefaultResultHandler<TransactionID>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v1/transactions"))
            .httpMethod(.post)
            .httpHeaders(algorandAuthenticatedHeaders())
            .resultHandler(handler)
            .context(.upload(.data(transactionData)))
            .buildAndSend(self)
    }
    
    @discardableResult
    func getTransactionParams(then handler: @escaping Endpoint.DefaultResultHandler<TransactionParams>) -> EndpointOperatable {
        return Endpoint(path: Path("/v1/transactions/params"))
            .httpMethod(.get)
            .httpHeaders(algorandAuthenticatedHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
}

extension API {
    private enum Formatter {
        static let date: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter
        }()
    }
}
