//
//  API+Transaction.swift

import Magpie
import SwiftDate

extension AlgorandAPI {
    @discardableResult
    func fetchTransactions(
        with draft: TransactionFetchDraft,
        then handler: @escaping (Response.ModelResult<TransactionList>) -> Void
    ) -> EndpointOperatable {
        var from: String?
        var to: String?
        
        if let fromDate = draft.dates.from,
            let toDate = draft.dates.to {
            from = "\(fromDate.toFormat("yyyy-MM-dd"))T00:00:00.000Z"
            to = "\(toDate.toFormat("yyyy-MM-dd"))T23:59:59.000Z"
        }
        
        return EndpointBuilder(api: self)
            .base(indexerBase)
            .path("/v2/accounts/\(draft.account.address)/transactions")
            .headers(indexerAuthenticatedHeaders())
            .query(TransactionsQuery(limit: draft.limit, from: from, to: to, next: draft.nextToken, assetId: draft.assetId))
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func sendTransaction(
        with transactionData: Data,
        then handler: @escaping (Response.ModelResult<TransactionID>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(algodBase)
            .path("/v2/transactions")
            .method(.post)
            .headers(algodBinaryAuthenticatedHeaders())
            .completionHandler(handler)
            .type(.upload(.data(transactionData)))
            .build()
            .send()
    }
    
    @discardableResult
    func getTransactionParams(
        then handler: @escaping (Response.ModelResult<TransactionParams>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(algodBase)
            .path("/v2/transactions/params")
            .headers(algodAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func trackTransaction(with draft: TransactionTrackDraft) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/transactions/")
            .method(.post)
            .headers(mobileApiHeaders())
            .body(draft)
            .build()
            .send()
    }
    
    @discardableResult
    func fetchPendingTransactions(
        for address: String,
        then handler: @escaping (Response.ModelResult<PendingTransactionList>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(algodBase)
            .path("/v2/accounts/\(address)/transactions/pending")
            .headers(algodAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
}

extension AlgorandAPI {
    private enum Formatter {
        static let date: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter
        }()
    }
}
