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
//  AccountTransactionHistoryDataSource.swift

import UIKit
import MagpieCore

final class TransactionHistoryDataSourceController: NSObject {
    private(set) var transactions = [TransactionItem]()
    private var account: Account
    private var assetDetail: AssetDetail?
    private var contacts = [Contact]()
    private var csvTransactions = [Transaction]()

    private let api: ALGAPI?

    private var transactionParams: TransactionParams?
    private var fetchRequest: EndpointOperatable?
    private var nextToken: String?

    private var hasNext: Bool {
        return nextToken != nil
    }

    private let paginationRequestThreshold = 5

    var openRewardDetailHandler: ((TransactionHistoryDataSourceController) -> Void)?
    var openFilterOptionsHandler: ((TransactionHistoryDataSourceController) -> Void)?
    var shareHistoryHandler: ((TransactionHistoryDataSourceController) -> Void)?
    var copyAssetIDHandler: ((TransactionHistoryDataSourceController, _ assetID: String?) -> Void)?

    private let draft: AssetDetailDraftProtocol

    init(api: ALGAPI?, provider: AssetDetailDraftProtocol) {
        self.draft = provider
        self.api = api
        self.account = provider.account
        self.assetDetail = provider.assetDetail
        super.init()
    }
}

extension TransactionHistoryDataSourceController {
    struct TransactionHistoryDraft: Hashable {
        static func == (
            lhs: TransactionHistoryDataSourceController.TransactionHistoryDraft,
            rhs: TransactionHistoryDataSourceController.TransactionHistoryDraft
        ) -> Bool {
            lhs.title == rhs.title && lhs.item?.uuid == rhs.item?.uuid
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(item?.uuid)
            hasher.combine(title)
        }
        
        /// According to current design, title can represent TransactionItem's date or "Pending Transaction"
        var title: String? = nil
        var item: TransactionItem? = nil
    }
}

extension TransactionHistoryDataSourceController {
    func dequeueAlgosDetailInfoViewCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> AlgosDetailInfoViewCell {
        let cell = collectionView.dequeue(AlgosDetailInfoViewCell.self, at: indexPath)
        cell.delegate = self
        cell.bindData(AlgosDetailInfoViewModel(account))
        return cell
    }

    func dequeueAssetDetailInfoViewCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> AssetDetailInfoViewCell {
        guard let assetDetail = assetDetail else {
            fatalError("AssetDetail should be set")
        }
        let cell = collectionView.dequeue(AssetDetailInfoViewCell.self, at: indexPath)
        cell.bindData(AssetDetailInfoViewModel(account: account, assetDetail: assetDetail))
        cell.delegate = self
        return cell
    }
}

extension TransactionHistoryDataSourceController {
    func dequeueTransactionHistoryFilterCell(
        in collectionView: UICollectionView,
        with filterOption: TransactionFilterViewController.FilterOption,
        at indexPath: IndexPath
    ) -> TransactionHistoryFilterCell { 
        let header = collectionView.dequeue(TransactionHistoryFilterCell.self, at: indexPath)
        header.bindData(TransactionHistoryFilterViewModel(filterOption))
        header.delegate = self
        return header
    }

    func dequeueHistoryTitleCell(
        in collectionView: UICollectionView,
        with title: String,
        at indexPath: IndexPath
    ) -> TransactionHistoryTitleCell {
        let cell = collectionView.dequeue(TransactionHistoryTitleCell.self, at: indexPath)
        cell.bindData(TransactionHistoryTitleContextViewModel(title: title))
        return cell
    }

    func dequeueHistoryCell(
        in collectionView: UICollectionView,
        with transaction: Transaction,
        at indexPath: IndexPath
    ) -> TransactionHistoryCell {
        let cell = collectionView.dequeue(TransactionHistoryCell.self, at: indexPath)
        
        if let assetTransaction = transaction.assetTransfer {
            if assetTransaction.receiverAddress == account.address {
                configure(cell, with: transaction, for: transaction.sender)
            } else {
                configure(cell, with: transaction, for: assetTransaction.receiverAddress)
            }
        } else if let payment = transaction.payment {
            if payment.receiver == account.address {
                configure(cell, with: transaction, for: transaction.sender)
            } else {
                configure(cell, with: transaction, for: transaction.payment?.receiver)
            }
        }
        return cell
    }

    func dequeueHistoryCell(
        in collectionView: UICollectionView,
        with reward: Reward,
        at indexPath: IndexPath
    ) -> TransactionHistoryCell {
        let cell = collectionView.dequeue(TransactionHistoryCell.self, at: indexPath)
        cell.bindData(
            TransactionHistoryContextViewModel(
                rewardViewModel: RewardViewModel(reward)
            )
        )
        return cell
    }
    
    func configure(_ cell: TransactionHistoryCell, with transaction: Transaction, for address: String?) {
        if let contact = contacts.first(where: { contact in
            contact.address == address
        }) {
            transaction.contact = contact
            let config = TransactionViewModelDependencies(
                account: account,
                assetDetail: assetDetail,
                transaction: transaction,
                contact: contact
            )
            cell.bindData(TransactionHistoryContextViewModel(transactionDependencies: config))
        } else {
            let config = TransactionViewModelDependencies(account: account, assetDetail: assetDetail, transaction: transaction)
            cell.bindData(TransactionHistoryContextViewModel(transactionDependencies: config))
        }
    }
    
    func dequeuePendingCell(
        in collectionView: UICollectionView,
        with transaction: PendingTransaction,
        at indexPath: IndexPath
    ) -> PendingTransactionCell {
        let cell = collectionView.dequeue(PendingTransactionCell.self, at: indexPath)
        let address = transaction.receiver == account.address ? transaction.sender : transaction.receiver
        configure(cell, with: transaction, for: address)
        cell.startAnimatingIndicator()
        return cell
    }
    
    func configure(_ cell: PendingTransactionCell, with transaction: PendingTransaction, for address: String?) {
        if let contact = contacts.first(where: { contact  in
            contact.address == address
        }) {
            transaction.contact = contact
            let config = TransactionViewModelDependencies(
                account: account,
                assetDetail: assetDetail,
                transaction: transaction,
                contact: contact
            )
            cell.bindData(TransactionHistoryContextViewModel(pendingTransactionDependencies: config))
        } else {
            let config = TransactionViewModelDependencies(account: account, assetDetail: assetDetail, transaction: transaction)
            cell.bindData(TransactionHistoryContextViewModel(pendingTransactionDependencies: config))
        }
    }
}

extension TransactionHistoryDataSourceController {
    func loadData(
        for account: Account,
        withRefresh refresh: Bool,
        between dates: (Date?, Date?),
        isPaginated: Bool,
        then handler: @escaping ([TransactionItem]?, APIError?) -> Void
    ) {
        api?.getTransactionParams { response in
            switch response {
            case let .failure(apiError, _):
                handler(nil, apiError)
            case let .success(params):
                self.transactionParams = params
                self.fetchTransactions(for: account, between: dates, withRefresh: refresh, isPaginated: isPaginated, then: handler)
            }
        }
    }
}

extension TransactionHistoryDataSourceController {
    private func fetchTransactions(
        for account: Account,
        between dates: (Date?, Date?),
        withRefresh refresh: Bool,
        isPaginated: Bool,
        limit: Int = 15,
        then handler: @escaping ([TransactionItem]?, APIError?) -> Void
    ) {
        var assetId: String?
        if let id = assetDetail?.id {
            assetId = String(id)
        }
        
        let draft = TransactionFetchDraft(account: account, dates: dates, nextToken: nextToken, assetId: assetId, limit: limit)
        fetchRequest = api?.fetchTransactions(draft) { response in
            switch response {
            case let .failure(apiError, _):
                handler(nil, apiError)
            case let .success(transactions):
                if refresh {
                    self.transactions.removeAll()
                }
                
                transactions.transactions.forEach { transaction in
                    transaction.status = .completed
                }
                
                self.nextToken = transactions.nextToken
                
                if let rewardDisplayPreference = self.api?.session.rewardDisplayPreference,
                    rewardDisplayPreference == .allowed,
                    self.assetDetail == nil {
                    self.setRewards(from: transactions, for: account, isPaginated: isPaginated)
                } else {
                    let filteredTrnsactions = transactions.transactions.filter { transaction in
                        if let assetDetail = self.assetDetail {
                            guard let assetId = transaction.assetTransfer?.assetId else {
                                return false
                            }
                            if transaction.isAssetCreationTransaction(for: account.address) {
                                return false
                            }
                            return assetId == assetDetail.id
                        } else {
                            if let assetTransfer = transaction.assetTransfer,
                                assetTransfer.receiverAddress == account.address,
                                assetTransfer.amount == 0 {
                                return true
                            }
                            return transaction.payment != nil
                        }
                    }
                    
                    if isPaginated {
                        self.transactions.append(contentsOf: filteredTrnsactions)
                    } else {
                        self.transactions = filteredTrnsactions
                    }
                }
                
                handler(self.transactions, nil)
            }
        }
    }
}

extension TransactionHistoryDataSourceController {
    private func setRewards(from transactions: TransactionList, for account: Account, isPaginated: Bool) {
        let filteredTransactions = transactions.transactions.filter { transaction in
            if let assetTransfer = transaction.assetTransfer,
                assetTransfer.receiverAddress == account.address,
                assetTransfer.amount == 0 {
                return true
            }
            return transaction.payment != nil && assetDetail == nil
        }
        
        for transaction in filteredTransactions {
            self.transactions.append(transaction)
            if let rewards = transaction.getRewards(for: account.address),
               rewards > 0 {
                let reward = Reward(amount: UInt64(rewards), date: transaction.date)
                self.transactions.append(reward)
            }
        }
    }
}

extension TransactionHistoryDataSourceController {
    func fetchPendingTransactions(for account: Account, then handler: @escaping ([PendingTransaction]?, APIError?) -> Void) {
        api?.fetchPendingTransactions(account.address) { response in
            switch response {
            case let .success(pendingTransactionList):
                self.filter(pendingTransactionList.pendingTransactions)
                handler(pendingTransactionList.pendingTransactions, nil)
            case let .failure(apiError, _):
                handler(nil, apiError)
            }
        }
    }
    
    private func filter(_ pendingTransactions: [PendingTransaction]) {
        let filteredTransactions = transactions.filter { ($0 as? PendingTransaction)?.signature != nil }
        if filteredTransactions.count == pendingTransactions.count {
            return
        }
        
        self.transactions = self.transactions.filter { item in
            guard let transactionItem = item as? Transaction,
                transactionItem.status == .pending else {
                return true
            }
            
            let containsPendingTransaction = pendingTransactions.contains { pendingTransaction in
                transactionItem.transactionSignature?.signature == pendingTransaction.signature
            }
            
            return !containsPendingTransaction
        }
    }
}

extension TransactionHistoryDataSourceController {
    func setupContacts() {
        contacts.removeAll()
        fetchContacts()
    }
    
    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }
                
                self.contacts.append(contentsOf: results)
            default:
                break
            }
        }
    }
    
    func transactionCount() -> Int {
        return transactions.count
    }
    
    func clear() {
        fetchRequest?.cancel()
        nextToken = nil
        transactions.removeAll()
    }
    
    var isEmpty: Bool {
        transactions.isEmpty
    }
    
    func shouldSendPaginatedRequest(at index: Int) -> Bool {
        if transactionCount() < paginationRequestThreshold {
            return index == transactionCount() - 1 && hasNext
        }
        
        return index == transactionCount() - paginationRequestThreshold && hasNext
    }
    
    func updateAssetDetail(_ assetDetail: AssetDetail?) {
        self.assetDetail = assetDetail
    }
}

extension TransactionHistoryDataSourceController: TransactionHistoryFilterCellDelegate {
    func transactionHistoryFilterCellDidOpenFilterOptions(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryFilterCell
    ) {
        openFilterOptionsHandler?(self)
    }
    
    func transactionHistoryFilterCellDidShareHistory(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryFilterCell
    ) {
        shareHistoryHandler?(self)
    }
}

extension TransactionHistoryDataSourceController {
    func fetchAllTransactions(
        for account: Account,
        between dates: (Date?, Date?),
        nextToken token: String?,
        then handler: @escaping ([Transaction]?, APIError?) -> Void
    ) {
        var assetId: String?
        if let id = assetDetail?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(account: account, dates: dates, nextToken: token, assetId: assetId, limit: nil)

        api?.fetchTransactions(draft) { response in
            switch response {
            case let .failure(apiError, _):
                handler(nil, apiError)
            case let .success(transactions):
                self.csvTransactions.append(contentsOf: transactions.transactions)

                if transactions.nextToken == nil {
                    let fetchedTransactions = self.csvTransactions
                    self.csvTransactions.removeAll()
                    handler(fetchedTransactions, nil)
                    return
                }

                self.fetchAllTransactions(for: account, between: dates, nextToken: transactions.nextToken, then: handler)
            }
        }
    }
}

extension TransactionHistoryDataSourceController: AlgosDetailInfoViewCellDelegate {
    func algosDetailInfoViewCellDidTapInfoButton(_ algosDetailInfoViewCell: AlgosDetailInfoViewCell) {
        openRewardDetailHandler?(self)
    }
}

extension TransactionHistoryDataSourceController: AssetDetailInfoViewCellDelegate {
    func assetDetailInfoViewCellDidTapAssetID(_ assetDetailInfoViewCell: AssetDetailInfoViewCell, assetID: String?) {
        copyAssetIDHandler?(self, assetID)
    }
}
