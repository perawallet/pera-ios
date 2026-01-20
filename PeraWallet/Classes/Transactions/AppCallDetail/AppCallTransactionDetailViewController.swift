// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ApplicationCallTransactionDetailViewController.swift

import UIKit
import pera_wallet_core

final class AppCallTransactionDetailViewController: BaseScrollViewController {
    override var analyticsScreen: ALGAnalyticsScreen? {
        return .init(name: .transactionDetail)
    }

    private lazy var appCallTransactionDetailView = AppCallTransactionDetailView()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let account: Account
    private let transaction: TransactionItem
    private let transactionTypeFilter: TransactionTypeFilter
    private let assets: [Asset]?
    private let copyToClipboardController: CopyToClipboardController

    private lazy var bottomSheetTransition = BottomSheetTransition(
        presentingViewController: self
    )

    private lazy var appCallTransactionDetailViewModel = AppCallTransactionDetailViewModel(
        transaction: transaction,
        account: account,
        assets: assets
    )

    init(
        account: Account,
        transaction: TransactionItem,
        transactionTypeFilter: TransactionTypeFilter,
        assets: [Asset]?,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.transaction = transaction
        self.transactionTypeFilter = transactionTypeFilter
        self.assets = assets
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        title = String(localized: "title-app-call")
    }

    override func prepareLayout() {
        super.prepareLayout()

        addAppCallTransactionDetailView()
    }

    override func linkInteractors() {
        super.linkInteractors()

        appCallTransactionDetailView.delegate = self
    }

    override func bindData() {
        super.bindData()

        appCallTransactionDetailView.bindData(
            appCallTransactionDetailViewModel,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension AppCallTransactionDetailViewController {
    private func addAppCallTransactionDetailView() {
        appCallTransactionDetailView.customize(AppCallTransactionDetailViewTheme())

        contentView.addSubview(appCallTransactionDetailView)
        appCallTransactionDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AppCallTransactionDetailViewController: AppCallTransactionDetailViewDelegate {
    func contextMenuInteractionForAsset(
        in appCallTransactionDetailView: AppCallTransactionDetailView
    ) -> UIContextMenuConfiguration? {
        guard
            let assets = assets,
            assets.count == 1,
            let asset = assets.first
        else {
            return nil
        }

        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAssetID) {
                [unowned self] _ in

                self.copyToClipboardController.copyID(asset)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForSender(
        in appCallTransactionDetailView: AppCallTransactionDetailView
    ) -> UIContextMenuConfiguration? {
        guard let senderAddress = transaction.sender else {
            return nil
        }

        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                self.copyToClipboardController.copyAddress(senderAddress)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForApplicationID(
        in appCallTransactionDetailView: AppCallTransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyTransactionID) {
                [unowned self] _ in
                self.copyToClipboardController.copyApplicationCallAppID(self.transaction)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func contextMenuInteractionForTransactionID(
        in appCallTransactionDetailView: AppCallTransactionDetailView
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
        in appCallTransactionDetailView: AppCallTransactionDetailView
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration { _ in
            let copyActionItem = UIAction(item: .copyTransactionNote) {
                [unowned self] _ in
                self.copyToClipboardController.copyNote(self.transaction)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func appCallTransactionDetailView(
        _ transactionDetailView: AppCallTransactionDetailView,
        didOpen explorer: AlgoExplorerType
    ) {
        let transactionId: String? = {
            if let tx = transaction as? Transaction { return tx.id ?? tx.parentID}
            if let tx = transaction as? TransactionV2 { return tx.id }
            return nil
        }()
        
        if let api = api,
           let transactionId,
           let url = explorer.transactionURL(with: transactionId, in: api.network) {
            open(url)
        }
    }

    func appCallTransactionDetailViewDidTapShowInnerTransactions(
        _ transactionDetailView: AppCallTransactionDetailView
    ) {
        let eventHandler: InnerTransactionListViewController.EventHandler = { [weak self] event in
            guard let self else { return }
            switch event {
            case .performClose: self.dismiss(animated: true)
            }
        }
        
        if let tx = transaction as? Transaction {
            openInnerTransactionList(with: tx.innerTransactions, and: eventHandler)
        }
        
        if let tx = transaction as? TransactionV2, let innerTransactions = tx.innerTransactions {
            let updatedInnerTxs = innerTransactions.map { innerTx in
                innerTx.parentId = tx.id
                return innerTx
            }
            openInnerTransactionList(with: updatedInnerTxs, and: eventHandler)
        }

    }
    
    private func openInnerTransactionList(with innerTransactions: [TransactionItem]?, and eventHandler: @escaping InnerTransactionListViewController.EventHandler) {
        guard let innerTransactions, !innerTransactions.isEmpty else { return }
            open(
                .innerTransactionList(
                    dataController: InnerTransactionListLocalDataController(
                        draft: InnerTransactionListDraft(
                            type: transactionTypeFilter,
                            asset: assets?.first,
                            account: account,
                            innerTransactions: innerTransactions
                        ),
                        sharedDataController: sharedDataController,
                        currency: sharedDataController.currency
                    ),
                    eventHandler: eventHandler
                ),
                by: .push
            )
        }
        
//        guard let transactionId = transaction.id else {
//            return
//        }
        
//        api?.fetchTransactionDetailV2(TransactionV2FetchDetailDraft(account: account, transactionId: transactionId)) { response in
//            switch response {
//            case .success(let transaction):
//                break
//            case .failure(let apiError, _):
//                break
//            }
//        }
        

    }

    func appCallTransactionDetailViewDidTapShowMoreAssets(
        _ transactionDetailView: AppCallTransactionDetailView
    ) {
        guard let assets = assets else {
            return
        }

        bottomSheetTransition.perform(
            .appCallAssetList(
                dataController: AppCallAssetListLocalDataController(
                    assets: assets
                )
            ),
            by: .present
        )
    }
}
