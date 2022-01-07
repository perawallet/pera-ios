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
//  TransactionsViewController.swift

import UIKit
import MagpieCore
import MacaroonUIKit

// <todo> Refactor DataSource & ViewController, it is tightly coupled to AssetDetailDraft.
class TransactionsViewController: BaseViewController {
    private lazy var theme = Theme()

    private lazy var bottomSheetTransition = BottomSheetTransition(presentingViewController: self)

    private var pendingTransactionPolling: PollingOperation?
    private(set) var account: Account
    private(set) var assetDetail: AssetDetail?
    private var isConnectedToInternet = true {
        didSet {
            if isConnectedToInternet {
                transactionListView.setInternetConnectionErrorState()
            } else {
                transactionListView.setNormalState()
            }
            applySnapshot()
        }
    }

    private var filterOption = TransactionFilterViewController.FilterOption.allTime
    private lazy var filterOptionsTransition = BottomSheetTransition(presentingViewController: self)
    
    private let transactionHistoryDataSourceController: TransactionHistoryDataSourceController
    private(set) lazy var transactionListView = TransactionListView()
    private var pendingTransactions: [TransactionHistoryItem] = []

    private let draft: AssetDetailDraftProtocol

    typealias DataSource = UICollectionViewDiffableDataSource<Section, TransactionHistoryItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TransactionHistoryItem>

    private lazy var currentSnapshot = Snapshot()

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: transactionListView.transactionsCollectionView) {
            [unowned self] collectionView, indexPath, identifier in

            switch identifier {
            case .info:
                // <todo> Move type to info
                if let cellType = draft.infoViewConfiguration?.cellType {
                    switch cellType {
                    case is AlgosDetailInfoViewCell.Type:
                        return transactionHistoryDataSourceController.dequeueAlgosDetailInfoViewCell(in: collectionView, at: indexPath)
                    case is AssetDetailInfoViewCell.Type:
                        return transactionHistoryDataSourceController.dequeueAssetDetailInfoViewCell(in: collectionView, at: indexPath)
                    default:
                        break
                    }
                }
            case .filter(let filterOption):
                return transactionHistoryDataSourceController.dequeueTransactionHistoryFilterCell(in: collectionView, with: filterOption, at: indexPath)
            case .title(let title):
                return transactionHistoryDataSourceController.dequeueHistoryTitleCell(in: collectionView, with: title, at: indexPath)
            case .transaction(transaction: let transaction):
                return transactionHistoryDataSourceController.dequeueHistoryCell(in: collectionView, with: transaction, at: indexPath)
            case .pending(pendingTransaction: let pendingTransaction):
                return transactionHistoryDataSourceController.dequeuePendingCell(in: collectionView, with: pendingTransaction, at: indexPath)
            case .reward(let reward):
                return transactionHistoryDataSourceController.dequeueHistoryCell(in: collectionView, with: reward, at: indexPath)
            }
            fatalError()
        }
        
        return dataSource
    }()

    init(draft: AssetDetailDraftProtocol, configuration: ViewControllerConfiguration) {
        self.draft = draft
        self.account = draft.account
        self.assetDetail = draft.assetDetail
        self.transactionHistoryDataSourceController = TransactionHistoryDataSourceController(
            api: configuration.api,
            draft: draft
        )
        super.init(configuration: configuration)
    }
    
    deinit {
        pendingTransactionPolling?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionHistoryDataSourceController.setupContacts()
        applySnapshot(animatingDifferences: false)
        fetchTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        api?.addListener(self)
        startPendingTransactionPolling()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        api?.removeListener(self)
        pendingTransactionPolling?.invalidate()
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: .ContactAddition,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactEdited(notification:)),
            name: .ContactEdit,
            object: nil
        )

        if draft.infoViewConfiguration?.cellType == AlgosDetailInfoViewCell.self {
            transactionHistoryDataSourceController.openRewardDetailHandler = { [weak self] _ in
                guard let self = self else {
                    return
                }

                self.bottomSheetTransition.perform(.rewardDetail(account: self.account))
            }
        } else if draft.infoViewConfiguration?.cellType == AssetDetailInfoViewCell.self {
            transactionHistoryDataSourceController.copyAssetIDHandler = { [weak self] _, assetID in
                guard  UIPasteboard.general.string != assetID else { return }
                self?.bannerController?.presentInfoBanner("asset-id-copied-title".localized)
                UIPasteboard.general.string = assetID
            }
        }
        
        transactionHistoryDataSourceController.openFilterOptionsHandler = { [weak self] _ in
            guard let self = self else {
                return
            }

            self.filterOptionsTransition.perform(.transactionFilter(filterOption: self.filterOption, delegate: self))
        }
        
        transactionHistoryDataSourceController.shareHistoryHandler = { [weak self] _ in
            self?.fetchAllTransactionsForCSV()
        }
    }
    
    override func linkInteractors() {
        transactionListView.delegate = self
        transactionListView.setCollectionViewDelegate(self)
    }
    
    override func prepareLayout() {
        if let cellType = draft.infoViewConfiguration?.cellType {
            transactionListView.transactionsCollectionView.register(cellType)
        }
        addTransactionListView()
    }
}

extension TransactionsViewController {
    private func addTransactionListView() {
        view.addSubview(transactionListView)
        transactionListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TransactionsViewController: TransactionListViewDelegate {
    func transactionListViewDidRefreshList(_ transactionListView: TransactionListView) {
        reloadData()
    }
    
    func transactionListViewDidTryAgain(_ transactionListView: TransactionListView) {
        reloadData()
    }
    
    private func reloadData() {
        transactionHistoryDataSourceController.clear()
        applySnapshot()
        fetchTransactions()
    }
}

extension TransactionsViewController {
    private func startPendingTransactionPolling() {
        pendingTransactionPolling = PollingOperation(interval: 0.8) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.transactionHistoryDataSourceController.fetchPendingTransactions(for: self.account) { pendingTransactions, error in
                if error != nil {
                    return
                }
                guard let pendingTransactions = pendingTransactions, !pendingTransactions.isEmpty else {
                    var currentSnapshot = self.currentSnapshot
                    currentSnapshot.deleteItems(self.pendingTransactions)
                    self.dataSource.apply(
                        currentSnapshot
                    )
                    self.pendingTransactions = []
                    return
                }
                
                self.transactionListView.setNormalState()
                let pendingTransactionsItems: [TransactionHistoryItem] = pendingTransactions.map {
                    return .pending(pendingTransaction: $0)
                }
                self.pendingTransactions = pendingTransactionsItems
                self.applySnapshot()
            }
        }
        
        pendingTransactionPolling?.start()
    }
    
    private func fetchTransactions(witRefresh refresh: Bool = true, isPaginated: Bool = false) {
        transactionListView.setLoadingState()
        
        transactionHistoryDataSourceController.loadData(
            for: account,
               withRefresh: refresh,
               between: getTransactionFilterDates(),
               isPaginated: isPaginated
        ) { transactions, error in
            self.transactionListView.endRefreshing()
            
            if !self.isConnectedToInternet {
                self.transactionListView.setInternetConnectionErrorState()
                self.applySnapshot()
                return
            }
            
            if let error = error {
                if !error.isCancelled {
                    self.transactionListView.setOtherErrorState()
                }
                self.applySnapshot()
                return
            }
            
            guard let transactions = transactions else {
                self.transactionListView.setNormalState()
                return
            }
            
            if transactions.isEmpty {
                self.transactionListView.setEmptyState()
                return
            }
            
            self.transactionListView.setNormalState()
            self.applySnapshot()
        }
    }
    
    private func getTransactionFilterDates() -> (from: Date?, to: Date?) {
        switch filterOption {
        case .allTime:
            return (nil, nil)
        case .today:
            return (Date().dateAt(.startOfDay), Date().dateAt(.endOfDay))
        case .yesterday:
            let yesterday = Date().dateAt(.yesterday)
            let endOfYesterday = yesterday.dateAt(.endOfDay)
            return (yesterday, endOfYesterday)
        case .lastWeek:
            let prevOfLastWeek = Date().dateAt(.prevWeek)
            let endOfLastWeek = prevOfLastWeek.dateAt(.endOfWeek)
            return (prevOfLastWeek, endOfLastWeek)
        case .lastMonth:
            let prevOfLastMonth = Date().dateAt(.prevMonth)
            let endOfLastMonth = prevOfLastMonth.dateAt(.endOfMonth)
            return (prevOfLastMonth, endOfLastMonth)
        case let .customRange(from, to):
            return (from, to)
        }
    }
}

extension TransactionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if transactionHistoryDataSourceController.shouldSendPaginatedRequest(at: indexPath.item) {
            fetchTransactions(witRefresh: false, isPaginated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section),
              section == .transactionHistory,
              case .transaction(let transaction) = dataSource.itemIdentifier(for: indexPath) else {
                  return
              }
        openTransactionDetail(transaction)
    }
    
    private func openTransactionDetail(_ transaction: Transaction) {
        if transaction.sender == account.address {
            open(
                .transactionDetail(
                    account: account,
                    transaction: transaction,
                    transactionType: .sent,
                    assetDetail: assetDetail
                ),
                by: .present
            )
        } else {
            open(
                .transactionDetail(
                    account: account,
                    transaction: transaction,
                    transactionType: .received,
                    assetDetail: assetDetail
                ),
                by: .present
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if let cellSize = draft.infoViewConfiguration?.infoViewSize,
           indexPath.section == 0 {
            return CGSize(cellSize)
        } else if case .title = dataSource.itemIdentifier(for: indexPath) {
            return CGSize(theme.transactionHistoryTitleCellSize)
        } else if case .filter = dataSource.itemIdentifier(for: indexPath) {
            return CGSize(theme.transactionHistoryFilterCellSize)
        } else {
            return CGSize(theme.transactionHistoryCellSize)
        }
    }
}

extension TransactionsViewController {
    @objc
    private func didContactAdded(notification: Notification) {
        transactionHistoryDataSourceController.setupContacts()
        applySnapshot()
    }
    
    @objc
    private func didContactEdited(notification: Notification) {
        transactionHistoryDataSourceController.setupContacts()
        applySnapshot()
    }
}

extension TransactionsViewController {
    func updateList() {
        transactionHistoryDataSourceController.clear()
        applySnapshot()
        transactionListView.setLoadingState()
        fetchTransactions()
    }
}

extension TransactionsViewController: TransactionFilterViewControllerDelegate {
    func transactionFilterViewController(
        _ transactionFilterViewController: TransactionFilterViewController,
        didSelect filterOption: TransactionFilterViewController.FilterOption
    ) {
        if self.filterOption == filterOption && !self.filterOption.isCustomRange() {
            return
        }
        
        switch filterOption {
        case .allTime:
            pendingTransactionPolling?.start()
        case let .customRange(_, to):
            if let isToDateLaterThanNow = to?.isAfterDate(Date(), granularity: .day),
               isToDateLaterThanNow {
                pendingTransactionPolling?.invalidate()
            } else {
                pendingTransactionPolling?.start()
            }
        default:
            pendingTransactionPolling?.invalidate()
        }

        self.filterOption = filterOption
        updateList()
    }
}

extension TransactionsViewController: CSVExportable {
    private func fetchAllTransactionsForCSV() {
        loadingController?.startLoadingWithMessage("title-loading".localized)

        transactionHistoryDataSourceController.fetchAllTransactions(
            for: account,
               between: getTransactionFilterDates(),
               nextToken: nil
        ) { transactions, error in
            if error != nil {
                self.loadingController?.stopLoading()
                return
            }
            
            guard let transactions = transactions else {
                self.loadingController?.stopLoading()
                return
            }
            
            self.shareCSVFile(for: transactions)
        }
    }
    
    private func shareCSVFile(for transactions: [Transaction]) {
        let keys: [String] = [
            "transaction-detail-amount".localized,
            "transaction-detail-reward".localized,
            "transaction-detail-close-amount".localized,
            "transaction-download-close-to".localized,
            "transaction-download-to".localized,
            "transaction-download-from".localized,
            "transaction-detail-fee".localized,
            "transaction-detail-round".localized,
            "transaction-detail-date".localized,
            "title-id".localized,
            "transaction-detail-note".localized
        ]
        let config = CSVConfig(fileName: formCSVFileName(), keys: NSOrderedSet(array: keys))
        
        if let fileUrl = exportCSV(from: createCSVData(from: transactions), with: config) {
            loadingController?.stopLoading()
            
            let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { _, _, _, _ in
                try? FileManager.default.removeItem(at: fileUrl)
            }
            present(activityViewController, animated: true)
        } else {
            loadingController?.stopLoading()
        }
    }
    
    private func formCSVFileName() -> String {
        var assetId = "algos"
        if let assetDetailId = assetDetail?.id {
            assetId = "\(assetDetailId)"
        }
        var fileName = "\(account.name ?? "")_\(assetId)"
        let dates = getTransactionFilterDates()
        if let fromDate = dates.from,
           let toDate = dates.to {
            if filterOption == .today {
                fileName += "-" + fromDate.toFormat("MM-dd-yyyy")
            } else {
                fileName += "-" + fromDate.toFormat("MM-dd-yyyy") + "_" + toDate.toFormat("MM-dd-yyyy")
            }
        }
        return "\(fileName).csv"
    }
    
    private func createCSVData(from transactions: [Transaction]) -> [[String: Any]] {
        var csvData = [[String: Any]]()
        for transaction in transactions {
            let transactionData: [String: Any] = [
                "transaction-detail-amount".localized: getFormattedAmount(transaction.getAmount()),
                "transaction-detail-reward".localized: transaction.getRewards(for: account.address)?.toAlgos ?? " ",
                "transaction-detail-close-amount".localized: getFormattedAmount(transaction.getCloseAmount()),
                "transaction-download-close-to".localized: transaction.getCloseAddress() ?? " ",
                "transaction-download-to".localized: transaction.getReceiver() ?? " ",
                "transaction-download-from".localized: transaction.sender ?? " ",
                "transaction-detail-fee".localized: transaction.fee?.toAlgos.toAlgosStringForLabel ?? " ",
                "transaction-detail-round".localized: transaction.lastRound ?? " ",
                "transaction-detail-date".localized: transaction.date?.toFormat("MMMM dd, yyyy - HH:mm") ?? " ",
                "title-id".localized: transaction.id ?? " ",
                "transaction-detail-note".localized: transaction.noteRepresentation() ?? " "
            ]
            csvData.append(transactionData)
        }
        return csvData
    }
    
    private func getFormattedAmount(_ amount: UInt64?) -> String {
        if let assetDetail = assetDetail {
            return amount?.toFractionStringForLabel(fraction: assetDetail.fractionDecimals) ?? " "
        } else {
            return amount?.toAlgos.toAlgosStringForLabel ?? " "
        }
    }
}

extension TransactionsViewController: APIListener {
    func api(
        _ api: API,
        networkMonitor: NetworkMonitor,
        didConnectVia connection: NetworkConnection,
        from oldConnection: NetworkConnection
    ) {
        if UIApplication.shared.isActive {
            isConnectedToInternet = networkMonitor.isConnected
        }
    }
    
    func api(_ api: API, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection) {
        if UIApplication.shared.isActive {
            isConnectedToInternet = networkMonitor.isConnected
        }
    }
}

extension TransactionsViewController {
    private func applySnapshot(
        animatingDifferences: Bool = true
    ) {
        var newSnapshot = Snapshot()

        newSnapshot.appendSections([.transactionHistory])

        if draft.infoViewConfiguration != nil {
            newSnapshot.insertSections([.info], beforeSection: .transactionHistory)

            newSnapshot.appendItems(
                [.info],
                toSection: .info
            )
        }

        newSnapshot.appendItems([.filter(filterOption: filterOption)], toSection: .transactionHistory)

        var transactionHistoryItems: [TransactionHistoryItem] = []

        if var currentDate = transactionHistoryDataSourceController.transactions.first?.date?.toFormat("MM-dd-yyyy") {
            let item: TransactionHistoryItem = .title(title: currentDate)
            transactionHistoryItems.append(item)

            for (_, transactionItem) in transactionHistoryDataSourceController.transactions.enumerated() {
                if let transactionItemDate = transactionItem.date,
                   transactionItemDate.toFormat("MM-dd-yyyy") != currentDate {
                    let item: TransactionHistoryItem = .title(title: transactionItemDate.toFormat("MM-dd-yyyy"))
                    transactionHistoryItems.append(item)
                    currentDate = transactionItemDate.toFormat("MM-dd-yyyy")
                }
                let item: TransactionHistoryItem
                if let transaction = transactionItem as? Transaction {
                    item = .transaction(transaction: transaction)
                } else if let reward = transactionItem as? Reward {
                    item = .reward(reward: reward)
                } else {
                    fatalError()
                }
                transactionHistoryItems.append(item)
            }
        }

        if !pendingTransactions.isEmpty {
            newSnapshot.appendItems(pendingTransactions, toSection: .transactionHistory)
        }

        newSnapshot.appendItems(
            transactionHistoryItems,
            toSection: .transactionHistory
        )
        self.currentSnapshot = newSnapshot
        dataSource.apply(
            newSnapshot,
            animatingDifferences: animatingDifferences
        )
    }
}

extension TransactionsViewController {
    enum Section: Int, CaseIterable {
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
}
