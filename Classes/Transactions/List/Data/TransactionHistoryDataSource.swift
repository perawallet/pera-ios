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

final class TransactionHistoryDataSource: NSObject, UICollectionViewDataSource {
    private var transactions = [TransactionItem]()
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

    var openRewardDetailHandler: ((TransactionHistoryDataSource) -> Void)?
    var openFilterOptionsHandler: ((TransactionHistoryDataSource) -> Void)?
    var shareHistoryHandler: ((TransactionHistoryDataSource) -> Void)?
    var copyAssetIDHandler: ((TransactionHistoryDataSource, _ assetID: String?) -> Void)?

    private let provider: AssetDetailConfigurationProtocol

    lazy var sections: [Section] = {
        var sections: [Section] = [.transactionHistory]
        if provider.infoViewConfiguration != nil {
            sections.insert(.info, at: 0)
        }
        return sections
    }()

    // <todo>: Sort
    var groupedTransactionItemsByDate: [TransactionHistoryDraft] {
        let groupedTransactionItemsByDate = Dictionary(grouping: transactions) {
            return $0.date?.toFormat("MMMM dd, yyyy")
        }

        var transactionHistoryViewModels: [TransactionHistoryDraft] = []

        for key in groupedTransactionItemsByDate.keys {
            let viewModel = TransactionHistoryDraft(date: key, item: nil)
            transactionHistoryViewModels.append(viewModel)
            for value in groupedTransactionItemsByDate[key] ?? [] {
                let viewModel = TransactionHistoryDraft(date: nil, item: value)
                transactionHistoryViewModels.append(viewModel)
            }
        }
        return transactionHistoryViewModels
    }

    init(api: ALGAPI?, provider: AssetDetailConfigurationProtocol) {
        self.provider = provider
        self.api = api
        self.account = provider.account
        self.assetDetail = provider.assetDetail
        super.init()
    }
}

extension TransactionHistoryDataSource {
    struct TransactionHistoryDraft {
        let date: String?
        let item: TransactionItem?
    }

    enum Section {
        case info
        case transactionHistory
    }
}

extension TransactionHistoryDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .info:
            return 1
        case .transactionHistory:
            return groupedTransactionItemsByDate.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .info:
            if let cellType = provider.infoViewConfiguration?.cellType {
                switch cellType {
                case is AlgosDetailInfoViewCell.Type:
                    return dequeueAlgosDetailInfoViewCell(in: collectionView, at: indexPath)
                case is AssetDetailInfoViewCell.Type:
                    return dequeueAssetDetailInfoViewCell(in: collectionView, at: indexPath)
                default:
                    break
                }
            }
        case .transactionHistory:
            let viewModel = groupedTransactionItemsByDate[indexPath.item]
            if let date = viewModel.date {
                return dequeueHistoryDateCell(in: collectionView, with: date, at: indexPath)
            } else {
                if let reward = viewModel.item as? Reward {
                    return dequeueHistoryCell(in: collectionView, with: reward, at: indexPath)
                } else if let transaction = viewModel.item as? Transaction {
                    return dequeueHistoryCell(in: collectionView, with: transaction, at: indexPath)
                } else if let transaction = viewModel.item as? PendingTransaction {
                    return dequeuePendingCell(in: collectionView, with: transaction, at: indexPath)
                }
            }
        }

        fatalError("Index path is out of bounds")
    }
}

extension TransactionHistoryDataSource {
    private func dequeueAlgosDetailInfoViewCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> AlgosDetailInfoViewCell {
        let cell = collectionView.dequeue(AlgosDetailInfoViewCell.self, at: indexPath)
        cell.delegate = self
        cell.bindData(AlgosDetailInfoViewModel(account))
        return cell
    }

    private func dequeueAssetDetailInfoViewCell(
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

extension TransactionHistoryDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueHeader(TransactionHistoryHeaderSupplementaryView.self, at: indexPath)
        header.delegate = self
        return header
    }
}

extension TransactionHistoryDataSource {
    private func dequeueHistoryDateCell(
        in collectionView: UICollectionView,
        with date: String,
        at indexPath: IndexPath
    ) -> TransactionHistoryDateCell {
        let cell = collectionView.dequeue(TransactionHistoryDateCell.self, at: indexPath)
        cell.bindData(TransactionHistoryDateContextViewModel(date: date))
        return cell
    }

    private func dequeueHistoryCell(
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

    private func dequeueHistoryCell(
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
    
    private func configure(_ cell: TransactionHistoryCell, with transaction: Transaction, for address: String?) {
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
    
    private func dequeuePendingCell(
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
    
    private func configure(_ cell: PendingTransactionCell, with transaction: PendingTransaction, for address: String?) {
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

extension TransactionHistoryDataSource {
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

extension TransactionHistoryDataSource {
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

extension TransactionHistoryDataSource {
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

extension TransactionHistoryDataSource {
    func fetchPendingTransactions(for account: Account, then handler: @escaping ([TransactionItem]?, APIError?) -> Void) {
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
        self.transactions.insert(contentsOf: pendingTransactions, at: 0)
    }
}

extension TransactionHistoryDataSource {
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
    
    func transaction(at indexPath: IndexPath) -> Transaction? {
        if indexPath.item >= 0 && indexPath.item < transactions.count {
            guard let transaction = transactions[indexPath.item] as? Transaction else {
                return nil
            }
            return transaction
        }
        
        return nil
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

extension TransactionHistoryDataSource: TransactionHistoryHeaderSupplementaryViewDelegate {
    func transactionHistoryHeaderSupplementaryViewDidOpenFilterOptions(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderSupplementaryView
    ) {
        openFilterOptionsHandler?(self)
    }
    
    func transactionHistoryHeaderSupplementaryViewDidShareHistory(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderSupplementaryView
    ) {
        shareHistoryHandler?(self)
    }
}

extension TransactionHistoryDataSource {
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

extension TransactionHistoryDataSource: AlgosDetailInfoViewCellDelegate {
    func algosDetailInfoViewCellDidTapInfoButton(_ algosDetailInfoViewCell: AlgosDetailInfoViewCell) {
        openRewardDetailHandler?(self)
    }
}

extension TransactionHistoryDataSource: AssetDetailInfoViewCellDelegate {
    func assetDetailInfoViewCellDidTapAssetID(_ assetDetailInfoViewCell: AssetDetailInfoViewCell, assetID: String?) {
        copyAssetIDHandler?(self, assetID)
    }
}
