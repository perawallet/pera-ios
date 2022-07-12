// Copyright 2022 Pera Wallet, LDA

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
//  TransactionDetailViewController.swift

import UIKit

final class TransactionDetailViewController: BaseScrollViewController {
    override var name: AnalyticsScreenName? {
        return .transactionDetail
    }
    
    private lazy var transactionDetailView = TransactionDetailView(transactionType: transactionType)

    private lazy var currencyFormatter = CurrencyFormatter()
    
    private var transaction: Transaction
    private let account: Account
    private var assetDetail: StandardAsset?
    private let transactionType: TransactionType

    private lazy var transactionDetailViewModel = TransactionDetailViewModel(
        transactionType: transactionType,
        transaction: transaction,
        account: account,
        assetDetail: assetDetail
    )

    private lazy var tooltipController = TooltipUIController(
        presentingView: view
    )

    private let copyToClipboardController: CopyToClipboardController
    
    init(
        account: Account,
        transaction: Transaction,
        transactionType: TransactionType,
        assetDetail: StandardAsset?,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.transaction = transaction
        self.transactionType = transactionType
        self.assetDetail = assetDetail
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }
    
    override func linkInteractors() {
        transactionDetailView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let tooltipDisplayStore = TooltipDisplayStore()

        if !tooltipDisplayStore.isDisplayedCopyAddressTooltip {
            tooltipDisplayStore.isDisplayedCopyAddressTooltip = true

            tooltipController.present(
                on: transactionDetailView.userView.detailLabel,
                title: "title-press-hold-copy-address".localized,
                duration: .default
            )
            return
        }
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: .ContactAddition,
            object: nil
        )
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        scrollView.customizeBaseAppearance(backgroundColor: AppColors.Shared.System.background)
        title = "transaction-detail-title".localized
        configureTransactionDetail()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addTransactionDetailView()
    }
}

extension TransactionDetailViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }
}

extension TransactionDetailViewController {
    private func addTransactionDetailView() {
        contentView.addSubview(transactionDetailView)
        transactionDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TransactionDetailViewController {
    @objc
    private func didContactAdded(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Contact],
              let contact = userInfo["contact"] else {
            return
        }
        
        transaction.contact = contact
        transactionDetailViewModel.bindOpponent(for: transaction, with: contact.address ?? "")
        transactionDetailView.bindOpponentViewDetail(transactionDetailViewModel)
    }
}

extension TransactionDetailViewController {
    private func configureTransactionDetail() {
        transactionDetailView.bindData(
            transactionDetailViewModel,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension TransactionDetailViewController: TransactionDetailViewDelegate {
    func transactionDetailViewDidTapAddContactButton(_ transactionDetailView: TransactionDetailView) {
        guard case let .address(address) = transactionDetailViewModel.opponentType else {
            return
        }
        open(.addContact(address: address), by: .push)
    }

    func contextMenuInteractionForUser(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                guard let address = self.getUserAddress(
                    transaction: transaction,
                    type: transactionType
                ) else {
                    return
                }

                self.copyToClipboardController.copyAddress(
                    address
                )
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    private func getUserAddress(
        transaction: Transaction,
        type: TransactionType
    ) -> String? {
        switch type {
        case .received:
            return transaction.getReceiver()
        case .sent:
            return transaction.sender
        }
    }

    func contextMenuInteractionForOpponent(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                let address = (self.transactionDetailViewModel.opponentType?.address).someString
                self.copyToClipboardController.copyAddress(address)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForCloseTo(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                let address = (self.transaction.payment?.closeAddress).someString
                self.copyToClipboardController.copyAddress(address)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForTransactionID(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyTransactionID) {
                [unowned self] _ in
                self.copyToClipboardController.copyID(self.transaction)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForTransactionNote(
        _ transactionDetailView: TransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyTransactionNote) {
                [unowned self] _ in
                self.copyToClipboardController.copyNote(self.transaction)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }
    
    func transactionDetailView(_ transactionDetailView: TransactionDetailView, didOpen explorer: AlgoExplorerType) {
        if let api = api,
           let transactionId = transaction.id ?? transaction.parentID,
           let url = explorer.transactionURL(with: transactionId, in: api.network) {
            open(url)
        }
    }
}

enum TransactionType {
    case sent
    case received
}

enum AlgoExplorerType {
    case algoexplorer
    case goalseeker

    func transactionURL(with id: String, in network: ALGAPI.Network) -> URL? {
        switch network {
        case .testnet:
            return testNetTransactionURL(with: id)
        case .mainnet:
            return mainNetTransactionURL(with: id)
        }
    }

    private func testNetTransactionURL(with id: String) -> URL? {
        switch self {
        case .algoexplorer:
            return URL(string: "https://testnet.algoexplorer.io/tx/\(id)")
        case .goalseeker:
            return URL(string: "https://goalseeker.purestake.io/algorand/testnet/transaction/\(id)")
        }
    }

    private func mainNetTransactionURL(with id: String) -> URL? {
        switch self {
        case .algoexplorer:
            return URL(string: "https://algoexplorer.io/tx/\(id)")
        case .goalseeker:
            return URL(string: "https://goalseeker.purestake.io/algorand/mainnet/transaction/\(id)")
        }
    }
}

extension TransactionDetailViewController {
    private final class TooltipDisplayStore: Storable {
        typealias Object = Any

        var isDisplayedCopyAddressTooltip: Bool {
            get { userDefaults.bool(forKey: isDisplayedCopyAddressTooltipKey) }
            set {
                userDefaults.set(newValue, forKey: isDisplayedCopyAddressTooltipKey)
                userDefaults.synchronize()
            }
        }

        private let isDisplayedCopyAddressTooltipKey =
        "cache.key.transactionDetailIsDisplayedCopyAddressTooltip"
    }
}
