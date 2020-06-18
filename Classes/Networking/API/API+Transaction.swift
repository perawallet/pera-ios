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
        for account: Account,
        max: Int = 100,
        then handler: @escaping Endpoint.DefaultResultHandler<TransactionList>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v2/accounts/\(account.address)/transactions"))
            .base(indexerBase)
            .httpMethod(.get)
            .httpHeaders(indexerAuthenticatedHeaders())
            .query(TransactionsQuery(limit: max))
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchTransactionDetail(
        for account: Account,
        with id: String,
        then handler: @escaping Endpoint.DefaultResultHandler<Transaction>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v2/transactions"))
            .base(indexerBase)
            .httpMethod(.get)
            .httpHeaders(indexerAuthenticatedHeaders())
            .query(TransactionSearchQuery(id: id))
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func sendTransaction(
        with transactionData: Data,
        then handler: @escaping Endpoint.DefaultResultHandler<TransactionID>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v2/transactions"))
            .base(algodBase)
            .httpMethod(.post)
            .httpHeaders(algodBinaryAuthenticatedHeaders())
            .resultHandler(handler)
            .context(.upload(.data(transactionData)))
            .buildAndSend(self)
    }
    
    @discardableResult
    func getTransactionParams(
        then handler: @escaping Endpoint.DefaultResultHandler<TransactionParams>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v2/transactions/params"))
            .base(algodBase)
            .httpMethod(.get)
            .httpHeaders(algodAuthenticatedHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func trackTransaction(with draft: TransactionTrackDraft) -> EndpointOperatable {
        return Endpoint(path: Path("/api/transactions/"))
            .base(mobileApiBase)
            .httpHeaders(mobileApiHeaders())
            .httpMethod(.post)
            .httpBody(draft)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchPendingTransactions(
        for address: String,
        then handler: @escaping Endpoint.DefaultResultHandler<PendingTransactionList>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v2/accounts/\(address)/transactions/pending"))
            .base(algodBase)
            .httpMethod(.get)
            .httpHeaders(algodAuthenticatedHeaders())
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
