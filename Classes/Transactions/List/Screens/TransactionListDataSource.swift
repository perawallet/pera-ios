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
//   TransactionListDataSource.swift

import UIKit
import MacaroonUIKit

final class TransactionListDataSource: NSObject {
    typealias DataSource = UICollectionViewDiffableDataSource<TransactionHistorySection, TransactionHistoryItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TransactionHistorySection, TransactionHistoryItem>

    lazy var handlers = Handlers()
    private lazy var currentSnapshot = Snapshot()

    private var contacts = [Contact]()
    private var transactions = [TransactionItem]()
    private var pendingTransactions = [PendingTransaction]()

    private let session: Session
    private let draft: TransactionListing
    private var filterOption: TransactionFilterViewController.FilterOption
    private weak var listView: UICollectionView?
    private weak var dataController: TransactionsDataController?

    init(
        session: Session,
        draft: TransactionListing,
        filterOption: TransactionFilterViewController.FilterOption,
        listView: UICollectionView,
        dataController: TransactionsDataController
    ) {
        self.session = session
        self.draft = draft
        self.filterOption = filterOption
        self.listView = listView
        self.dataController = dataController
        super.init()

        setDataControllerListeners()
    }

    private(set) lazy var dataSource: DataSource = {
        guard let listView = listView else {
            fatalError()
        }

        let dataSource = DataSource(collectionView: listView) {
            [unowned self] collectionView, indexPath, identifier in

            switch identifier {
            case .info:
                switch draft.type {
                case .algos:
                    let cell = collectionView.dequeue(AlgosDetailInfoViewCell.self, at: indexPath)
                    cell.delegate = self
                    cell.bindData(
                        AlgosDetailInfoViewModel(
                            draft.account
                        )
                    )
                    return cell
                case .asset:
                    let cell = collectionView.dequeue(AssetDetailInfoViewCell.self, at: indexPath)
                    cell.bindData(
                        AssetDetailInfoViewModel(
                            account: draft.account,
                            assetDetail: draft.assetDetail!
                        )
                    )
                    cell.delegate = self
                    return cell
                case .all:
                    fatalError("Info should not be set for all transactions")
                }
            case .filter(let filterOption):
                let cell = collectionView.dequeue(TransactionHistoryFilterCell.self, at: indexPath)
                cell.bindData(
                    TransactionHistoryFilterViewModel(
                        filterOption
                    )
                )
                cell.delegate = self
                return cell
            case .title(let title):
                let cell = collectionView.dequeue(TransactionHistoryTitleCell.self, at: indexPath)
                cell.bindData(
                    TransactionHistoryTitleContextViewModel(
                        title: title
                    )
                )
                return cell
            case let .transaction(transaction):
                let cell = collectionView.dequeue(TransactionHistoryCell.self, at: indexPath)

                if let assetTransaction = transaction.assetTransfer {
                    bind(
                        cell,
                        with: transaction,
                        for: assetTransaction.receiverAddress == draft.account.address ? transaction.sender : assetTransaction.receiverAddress
                    )
                } else if let payment = transaction.payment {
                    bind(
                        cell,
                        with: transaction,
                        for: payment.receiver == draft.account.address ? transaction.sender : transaction.payment?.receiver
                    )
                }

                return cell
            case let .pending(pendingTransaction):
                let cell = collectionView.dequeue(PendingTransactionCell.self, at: indexPath)

                bind(
                    cell,
                    with: pendingTransaction,
                    for: pendingTransaction.receiver == draft.account.address ? pendingTransaction.sender : pendingTransaction.receiver
                )
                cell.startAnimatingIndicator()

                return cell
            case let .reward(reward):
                let cell = collectionView.dequeue(TransactionHistoryCell.self, at: indexPath)
                cell.bindData(
                    TransactionHistoryContextViewModel(
                        rewardViewModel: RewardViewModel(reward)
                    )
                )
                return cell
            }
        }

        return dataSource
    }()

    func applySnapshot(
        animatingDifferences: Bool = true
    ) {
        var newSnapshot = Snapshot()

        if draft.type != .all {
            newSnapshot.appendSections([.info])
            newSnapshot.appendItems(
                [.info],
                toSection: .info
            )
        }

        newSnapshot.appendSections([.transactionHistory])
        newSnapshot.appendItems(
            [.filter(filterOption: filterOption)],
            toSection: .transactionHistory
        )

        let transactionsHistoryItems = getTransactionHistoryItemsWithDates()
        appendPendingTransactions(to: &newSnapshot)

        newSnapshot.appendItems(
            transactionsHistoryItems,
            toSection: .transactionHistory
        )

        self.currentSnapshot = newSnapshot
        dataSource.apply(
            newSnapshot,
            animatingDifferences: animatingDifferences
        )
    }

    private func appendPendingTransactions(
        to snapshot: inout Snapshot
    ) {
        if !pendingTransactions.isEmpty {
            let pendingTransactionsItems: [TransactionHistoryItem] = pendingTransactions.map {
                return .pending(pendingTransaction: $0)
            }

            snapshot.appendItems(
                [.title(title: "transaction-detail-pending-transactions".localized)] + pendingTransactionsItems,
                toSection: .transactionHistory
            )
        }
    }

    private func removePendingTransactionsFromSnapshot() {
        var currentSnapshot = dataSource.snapshot()

        let pendingTransactionsItems: [TransactionHistoryItem] = pendingTransactions.map {
            return .pending(pendingTransaction: $0)
        }

        currentSnapshot.deleteItems(
            [.title(title: "transaction-detail-pending-transactions".localized)] + pendingTransactionsItems
        )

        dataSource.apply(currentSnapshot)
        pendingTransactions = []
    }
}

extension TransactionListDataSource {
    func updateFilterOption(_ filterOption: TransactionFilterViewController.FilterOption) {
        self.filterOption = filterOption
    }

    func shouldSendPaginatedRequest(at index: Int) -> Bool {
        return dataController?.shouldSendPaginatedRequest(for: transactions, at: index) ?? false
    }

    func clear() {
        transactions.removeAll()
        pendingTransactions.removeAll()
        dataController?.clear()
    }
}

extension TransactionListDataSource {
    private func setDataControllerListeners() {
        guard let dataController = dataController else {
            return
        }

        dataController.handlers.didFetchContacts = { [weak self] contacts in
            guard let self = self else {
                return
            }

            self.contacts = contacts
        }

        dataController.handlers.didFetchTransactions = { [weak self] transactionList in
            guard let self = self else {
                return
            }

            transactionList.forEach { $0.status = .completed }
            self.groupTransactionsByType(transactionList, isPaginated: false)
            self.applySnapshot()
        }

        dataController.handlers.didFetchPaginatedTransactions = { [weak self] transactionList in
            guard let self = self else {
                return
            }

            transactionList.forEach { $0.status = .completed }
            self.groupTransactionsByType(transactionList, isPaginated: true)
            self.applySnapshot()
        }

        dataController.handlers.didFailToFetchTransactions = { _ in
            /// <todo> Handle error case
        }

        dataController.handlers.didFetchPendingTransactions = { [weak self] pendingTransactions in
            guard let self = self else {
                return
            }

            if pendingTransactions.isEmpty {
                self.removePendingTransactionsFromSnapshot()
                return
            }

            self.pendingTransactions = pendingTransactions
            self.applySnapshot()
        }

        dataController.handlers.didFailToFetchPendingTransactions = { _ in
            /// <todo> Handle error case
        }
    }
}

extension TransactionListDataSource {
    private func groupTransactionsByType(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        switch draft.type {
        case .algos:
            groupAlgoTransactions(
                transactions,
                isPaginated: isPaginated
            )
        case .asset:
            groupAssetTransactions(
                transactions,
                isPaginated: isPaginated
            )
        case .all:
            groupAllTransactions(
                transactions,
                isPaginated: isPaginated
            )
        }
    }

    private func groupAlgoTransactions(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        let filteredTransactions = transactions.filter { transaction in
            if transaction.isAssetAdditionTransaction(for: draft.account.address) {
                return true
            }

            return transaction.payment != nil
        }

        if session.rewardDisplayPreference == .allowed {
            setTransactionsWithRewards(
                filteredTransactions,
                isPaginated: isPaginated
            )
            return
        }


        setTransactionItems(
            filteredTransactions,
            isPaginated: isPaginated
        )
    }

    private func groupAssetTransactions(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        let filteredTransactions = transactions.filter { transaction in
            guard let assetId = transaction.assetTransfer?.assetId,
                  !transaction.isAssetCreationTransaction(for: draft.account.address) else {
                return false
            }

            return assetId == draft.assetDetail?.id
        }

        setTransactionItems(
            filteredTransactions,
            isPaginated: isPaginated
        )
    }

    private func groupAllTransactions(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        let filteredTransactions = transactions.filter { transaction in
            return transaction.type == .assetTransfer || transaction.type == .payment
        }

        if session.rewardDisplayPreference == .allowed {
            setTransactionsWithRewards(
                filteredTransactions,
                isPaginated: isPaginated
            )
            return
        }

        setTransactionItems(
            filteredTransactions,
            isPaginated: isPaginated
        )
    }

    private func setTransactionsWithRewards(
        _ transactions: [Transaction],
        isPaginated: Bool
    ) {
        var transactionsWithRewards: [TransactionItem] = []

        for transaction in transactions {
            transactionsWithRewards.append(transaction)
            if let rewards = transaction.getRewards(for: draft.account.address),
               rewards > 0 {
                let reward = Reward(amount: UInt64(rewards), date: transaction.date)
                transactionsWithRewards.append(reward)
            }
        }

        setTransactionItems(
            transactionsWithRewards,
            isPaginated: isPaginated
        )
    }

    private func setTransactionItems(
        _ newTransactions: [TransactionItem],
        isPaginated: Bool
    ) {
        self.transactions = isPaginated ? self.transactions + newTransactions : newTransactions
    }
}

extension TransactionListDataSource {
    private func getTransactionHistoryItemsWithDates() -> [TransactionHistoryItem] {
        var transactionHistoryItems: [TransactionHistoryItem] = []

        if var currentDate = transactions.first?.date?.toFormat("MMM d, yyyy") {
            let item: TransactionHistoryItem = .title(title: currentDate)
            transactionHistoryItems.append(item)

            for transaction in transactions {
                if let transactionDate = transaction.date,
                   transactionDate.toFormat("MMM d, yyyy") != currentDate {
                    let item: TransactionHistoryItem = .title(title: transactionDate.toFormat("MMM d, yyyy"))
                    transactionHistoryItems.append(item)
                    currentDate = transactionDate.toFormat("MMM d, yyyy")
                }

                if let transaction = transaction as? Transaction {
                    transactionHistoryItems.append(.transaction(transaction: transaction))
                } else if let reward = transaction as? Reward {
                    transactionHistoryItems.append(.reward(reward: reward))
                }
            }
        }

        return transactionHistoryItems
    }
}

extension TransactionListDataSource {
    private func bind(
        _ cell: TransactionHistoryCell,
        with transaction: Transaction,
        for address: String?
    ) {
        if let contact = contacts.first(where: { contact in
            contact.address == address
        }) {
            transaction.contact = contact
            let config = TransactionViewModelDependencies(
                account: draft.account,
                assetDetail: draft.assetDetail,
                transaction: transaction,
                contact: contact
            )
            cell.bindData(
                TransactionHistoryContextViewModel(
                    transactionDependencies: config
                )
            )

            return
        }

        let config = TransactionViewModelDependencies(
            account: draft.account,
            assetDetail: draft.assetDetail,
            transaction: transaction
        )
        cell.bindData(
            TransactionHistoryContextViewModel(
                transactionDependencies: config
            )
        )
    }

    private func bind(
        _ cell: PendingTransactionCell,
        with transaction: PendingTransaction,
        for address: String?
    ) {
        if let contact = contacts.first(where: { contact  in
            contact.address == address
        }) {
            transaction.contact = contact
            let config = TransactionViewModelDependencies(
                account: draft.account,
                assetDetail: draft.assetDetail,
                transaction: transaction,
                contact: contact
            )
            cell.bindData(
                TransactionHistoryContextViewModel(
                    pendingTransactionDependencies: config
                )
            )

            return
        }

        let config = TransactionViewModelDependencies(
            account: draft.account,
            assetDetail: draft.assetDetail,
            transaction: transaction
        )
        cell.bindData(
            TransactionHistoryContextViewModel(
                pendingTransactionDependencies: config
            )
        )
    }
}

extension TransactionListDataSource: AlgosDetailInfoViewCellDelegate {
    func algosDetailInfoViewCellDidTapInfoButton(_ algosDetailInfoViewCell: AlgosDetailInfoViewCell) {
        handlers.openRewardDetailHandler?()
    }
}

extension TransactionListDataSource: AssetDetailInfoViewCellDelegate {
    func assetDetailInfoViewCellDidTapAssetID(_ assetDetailInfoViewCell: AssetDetailInfoViewCell, assetID: String?) {
        handlers.copyAssetIDHandler?(assetID)
    }
}

extension TransactionListDataSource: TransactionHistoryFilterCellDelegate {
    func transactionHistoryFilterCellDidOpenFilterOptions(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryFilterCell
    ) {
        handlers.openFilterOptionsHandler?()
    }

    func transactionHistoryFilterCellDidShareHistory(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryFilterCell
    ) {
        handlers.shareHistoryHandler?()
    }
}

extension TransactionListDataSource {
    struct Handlers {
        var openRewardDetailHandler: EmptyHandler?
        var openFilterOptionsHandler: EmptyHandler?
        var shareHistoryHandler: EmptyHandler?
        var copyAssetIDHandler: ((String?) -> Void)?
    }
}

enum TransactionHistorySection: Int, CaseIterable {
    case info
    case transactionHistory
}

enum TransactionHistoryItem: Hashable {
    case info
    case filter(filterOption: TransactionFilterViewController.FilterOption)
    case transaction(transaction: Transaction)
    case pending(pendingTransaction: PendingTransaction)
    case reward(reward: Reward)
    case title(title: String)
}
