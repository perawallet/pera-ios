// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   TransactionsDataController.swift

import UIKit
import MagpieCore

final class TransactionsDataController: NSObject {
    lazy var handlers = Handlers()
    private var pendingTransactionPolling: PollingOperation?
    private var fetchRequest: EndpointOperatable?
    private var nextToken: String?
    private let paginationRequestThreshold = 5

    private let api: ALGAPI
    private let draft: TransactionListing

    init(api: ALGAPI, draft: TransactionListing) {
        self.draft = draft
        self.api = api
        super.init()
    }

    func clear() {
        nextToken = nil
        fetchRequest = nil
    }

    func shouldSendPaginatedRequest(for transactions: [TransactionItem], at index: Int) -> Bool {
        if transactions.count < paginationRequestThreshold {
            return index == transactions.count - 1 && nextToken != nil
        }

        return index == transactions.count - paginationRequestThreshold && nextToken != nil
    }
}

extension TransactionsDataController {
    func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }

                self.handlers.didFetchContacts?(results)
            default:
                break
            }
        }
    }
}

extension TransactionsDataController {
    func startPendingTransactionPolling() {
        pendingTransactionPolling = PollingOperation(interval: 0.8) { [weak self] in
            guard let self = self else {
                return
            }

            self.api.fetchPendingTransactions(self.draft.account.address) { [weak self] response in
                guard let self = self else {
                    return
                }
                switch response {
                case let .success(pendingTransactionList):
                    self.handlers.didFetchPendingTransactions?(pendingTransactionList.pendingTransactions)
                case let .failure(apiError, _):
                    self.handlers.didFailToFetchPendingTransactions?(apiError)
                }
            }
        }

        pendingTransactionPolling?.start()
    }

    func stopPendingTransactionPolling() {
        pendingTransactionPolling?.invalidate()
    }
}

extension TransactionsDataController {
    func fetchAllTransactions(
        between dates: (Date?, Date?),
        nextToken token: String?
    ) {
        var assetId: String?
        if let id = draft.assetDetail?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(account: draft.account, dates: dates, nextToken: token, assetId: assetId, limit: nil)
        var csvTransactions = [Transaction]()

        api.fetchTransactions(draft) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .failure(apiError, _):
                self.handlers.didFailToFetchCSVTransactions?(apiError)
            case let .success(transactions):
                csvTransactions.append(contentsOf: transactions.transactions)

                if transactions.nextToken == nil {
                    self.handlers.didFetchCSVTransactions?(csvTransactions)
                    return
                }

                self.fetchAllTransactions(between: dates, nextToken: transactions.nextToken)
            }
        }
    }
}

extension TransactionsDataController {
    func fetchTransactions(
        between dates: (Date?, Date?)
    ) {
        var assetId: String?
        if let id = draft.assetDetail?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(account: draft.account, dates: dates, nextToken: nil, assetId: assetId, limit: 30)
        fetchRequest = api.fetchTransactions(draft) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .failure(apiError, _):
                self.handlers.didFailToFetchTransactions?(apiError)
            case let .success(transactionResults):
                self.nextToken = transactionResults.nextToken
                self.handlers.didFetchTransactions?(transactionResults.transactions)
            }
        }
    }

    func fetchPaginatedTransactions(
        between dates: (Date?, Date?)
    ) {
        var assetId: String?
        if let id = draft.assetDetail?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(account: draft.account, dates: dates, nextToken: nextToken, assetId: assetId, limit: 30)
        fetchRequest = api.fetchTransactions(draft) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .failure(apiError, _):
                self.handlers.didFailToFetchTransactions?(apiError)
            case let .success(transactionResults):
                self.nextToken = transactionResults.nextToken
                self.handlers.didFetchPaginatedTransactions?(transactionResults.transactions)
            }
        }
    }
}

extension TransactionsDataController {
    struct Handlers {
        var didFetchContacts: (([Contact]) -> Void)?
        var didFetchTransactions: (([Transaction]) -> Void)?
        var didFetchPaginatedTransactions: (([Transaction]) -> Void)?
        var didFailToFetchTransactions: ((APIError) -> Void)?
        var didFetchPendingTransactions: (([PendingTransaction]) -> Void)?
        var didFailToFetchPendingTransactions: ((APIError) -> Void)?
        var didFetchCSVTransactions: (([Transaction]) -> Void)?
        var didFailToFetchCSVTransactions: ((APIError) -> Void)?
    }
}
