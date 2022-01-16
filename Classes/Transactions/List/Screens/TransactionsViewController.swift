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

class TransactionsViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var bottomSheetTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var filterOptionsTransition = BottomSheetTransition(presentingViewController: self)

    private(set) var account: Account
    private(set) var assetDetail: AssetInformation?
    private(set) var filterOption = TransactionFilterViewController.FilterOption.allTime

    private lazy var listLayout = TransactionsListLayout(
        draft: draft,
        transactionDataSource: transactionsDataSource
    )
    private(set) lazy var dataController = TransactionsDataController(
        api: api!,
        draft: draft
    )
    private lazy var transactionsDataSource = TransactionListDataSource(
        session: session!,
        draft: draft,
        filterOption: filterOption,
        listView: listView,
        dataController: dataController
    )

    private(set) lazy var listView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.register(TransactionHistoryCell.self)
        collectionView.register(PendingTransactionCell.self)
        collectionView.register(TransactionHistoryTitleCell.self)
        collectionView.register(TransactionHistoryFilterCell.self)
        collectionView.register(AlgosDetailInfoViewCell.self)
        collectionView.register(AssetDetailInfoViewCell.self)
        return collectionView
    }()

    private lazy var transactionActionButton = FloatingActionItemButton(hasTitleLabel: false)
    private let draft: TransactionListing

    init(draft: TransactionListing, configuration: ViewControllerConfiguration) {
        self.draft = draft
        self.account = draft.account
        self.assetDetail = draft.assetDetail
        super.init(configuration: configuration)
    }
    
    deinit {
        dataController.stopPendingTransactionPolling()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController.fetchContacts()
        transactionsDataSource.applySnapshot(animatingDifferences: false)

        dataController.fetchTransactions(
            between: getTransactionFilterDates()
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataController.startPendingTransactionPolling()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataController.stopPendingTransactionPolling()
    }
    
    override func setListeners() {
        setNotificationObservers()
        setListLayoutListeners()
        setDataSourceListeners()
        transactionActionButton.addTarget(self, action: #selector(didTapTransactionActionButton), for: .touchUpInside)
    }

    override func prepareLayout() {
        addListView()
        addTransactionActionButton(theme)
    }

    override func linkInteractors() {
        listView.delegate = listLayout
        listView.dataSource = transactionsDataSource.dataSource
    }
}

extension TransactionsViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addTransactionActionButton(_ theme: Theme) {
        transactionActionButton.image = "fab-swap".uiImage
        
        view.addSubview(transactionActionButton)
        transactionActionButton.snp.makeConstraints {
            $0.setPaddings(theme.transactionActionButtonPaddings)
        }
    }
}

extension TransactionsViewController {
    private func setNotificationObservers() {
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
    }

    private func setListLayoutListeners() {
        listLayout.handlers.didSelectTransaction = { [weak self] transaction in
            guard let self = self else {
                return
            }

            self.openTransactionDetail(transaction)
        }

        listLayout.handlers.willDisplay = { [weak self] indexPath in
            guard let self = self else {
                return
            }

            if self.transactionsDataSource.shouldSendPaginatedRequest(at: indexPath.item) {
                self.dataController.fetchPaginatedTransactions(
                    between: self.getTransactionFilterDates()
                )
            }
        }
    }

    private func setDataSourceListeners() {
        if draft.type == .algos {
            transactionsDataSource.handlers.openRewardDetailHandler = { [weak self] in
                guard let self = self else {
                    return
                }

                self.bottomSheetTransition.perform(
                    .rewardDetail(account: self.account),
                    by: .presentWithoutNavigationController
                )
            }
        } else if draft.type == .asset {
            transactionsDataSource.handlers.copyAssetIDHandler = { [weak self] assetID in
                guard  UIPasteboard.general.string != assetID else { return }
                self?.bannerController?.presentInfoBanner("asset-id-copied-title".localized)
                UIPasteboard.general.string = assetID
            }
        }

        transactionsDataSource.handlers.openFilterOptionsHandler = { [weak self] in
            guard let self = self else {
                return
            }

            self.filterOptionsTransition.perform(
                .transactionFilter(filterOption: self.filterOption, delegate: self),
                by: .presentWithoutNavigationController
            )
        }

        transactionsDataSource.handlers.shareHistoryHandler = { [weak self] in
            guard let self = self else {
                return
            }

            self.fetchAllTransactionsForCSV()
        }
    }

    private func setDataControllerListeners() {
        dataController.handlers.didFetchCSVTransactions = { [weak self] transactions in
            guard let self = self else {
                return
            }

            self.shareCSVFile(for: transactions)
        }

        dataController.handlers.didFailToFetchCSVTransactions = { [weak self] _ in
            guard let self = self else {
                return
            }

            self.loadingController?.stopLoading()
        }
    }
}

extension TransactionsViewController {
    @objc
    private func didTapTransactionActionButton() {
        let viewController = open(
            .transactionFloatingActionButton,
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: false
        ) as? TransactionFloatingActionButtonViewController

        viewController?.delegate = self
    }
}

extension TransactionsViewController: TransactionFloatingActionButtonViewControllerDelegate {
    func transactionFloatingActionButtonViewControllerDidSend(_ viewController: TransactionFloatingActionButtonViewController) {
        log(SendAssetDetailEvent(address: account.address))
        
        let draft: SendTransactionDraft

        if let assetDetail = assetDetail {
            draft = SendTransactionDraft(from: account, transactionMode: .assetDetail(assetDetail))
        } else {
            draft = SendTransactionDraft(from: account, transactionMode: .algo)
        }

        let controller = open(.sendTransaction(draft: draft), by: .present) as? SendTransactionScreen
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            controller?.closeScreen(by: .dismiss, animated: true)
        }
        controller?.leftBarButtonItems = [closeBarButtonItem]
    }

    func transactionFloatingActionButtonViewControllerDidReceive(_ viewController: TransactionFloatingActionButtonViewController) {
        log(ReceiveAssetDetailEvent(address: account.address))
        let draft = QRCreationDraft(address: account.address, mode: .address, title: account.name)
        open(.qrGenerator(title: account.name ?? account.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
    }
}

extension TransactionsViewController {
    private func reloadData() {
        transactionsDataSource.clear()
        transactionsDataSource.applySnapshot()

        dataController.fetchTransactions(
            between: getTransactionFilterDates()
        )
    }
}

extension TransactionsViewController {
    func getTransactionFilterDates() -> (from: Date?, to: Date?) {
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

extension TransactionsViewController {
    private func openTransactionDetail(_ transaction: Transaction) {
        if transaction.sender == account.address {
            open(
                .transactionDetail(
                    account: account,
                    transaction: transaction,
                    transactionType: .sent,
                    assetDetail: getAssetDetailForTransactionType(transaction)
                ),
                by: .present
            )

            return
        }

        open(
            .transactionDetail(
                account: account,
                transaction: transaction,
                transactionType: .received,
                assetDetail: getAssetDetailForTransactionType(transaction)
            ),
            by: .present
        )
    }

    private func getAssetDetailForTransactionType(_ transaction: Transaction) -> AssetInformation? {
        switch draft.type {
        case .all:
            if let assetId = transaction.assetTransfer?.assetId {
                return account.assetInformations.first(matching: (\.id, assetId))
            }

            return assetDetail
        case .algos,
                .asset:
            return assetDetail
        }
    }
}

extension TransactionsViewController {
    @objc
    private func didContactAdded(notification: Notification) {
        dataController.fetchContacts()
        transactionsDataSource.applySnapshot()
    }
    
    @objc
    private func didContactEdited(notification: Notification) {
        dataController.fetchContacts()
        transactionsDataSource.applySnapshot()
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
            dataController.startPendingTransactionPolling()
        case let .customRange(_, to):
            if let isToDateLaterThanNow = to?.isAfterDate(Date(), granularity: .day),
               isToDateLaterThanNow {
                dataController.stopPendingTransactionPolling()
            } else {
                dataController.startPendingTransactionPolling()
            }
        default:
            dataController.startPendingTransactionPolling()
        }

        self.filterOption = filterOption
        transactionsDataSource.updateFilterOption(filterOption)
        reloadData()
    }
}
