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
//  ManageAssetsViewController.swift

import UIKit
import MagpieHipo

final class ManageAssetsViewController:
    BaseViewController,
    TransactionSignChecking {
    weak var delegate: ManageAssetsViewControllerDelegate?
    
    private lazy var theme = Theme()
    
    private lazy var listLayout = ManageAssetsListLayout(dataSource)
    private lazy var dataSource = ManageAssetsListDataSource(contextView.assetsCollectionView)

    private lazy var transitionToOptOutAsset = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToTransferAssetBalance = BottomSheetTransition(presentingViewController: self)

    private lazy var contextView = ManageAssetsView()
    
    private var account: Account {
        return dataController.account
    }

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private var optOutTransactions: [AssetID: AssetOptOutTransaction] = [:]

    private var transactionControllers: [TransactionController] {
        return Array(optOutTransactions.values.map { $0.transactionController })
    }

    private lazy var currencyFormatter = CurrencyFormatter()

    private let dataController: ManageAssetsListDataController

    init(
        dataController: ManageAssetsListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            case .didOptOutAssets(let items):
                for item in items {
                    if let indexPath = self.dataSource.indexPath(for: .asset(item)),
                       let cell = self.contextView.assetsCollectionView.cellForItem(at: indexPath) {
                        self.configureAccessory(
                            cell as? OptOutAssetListItemCell,
                            for: item
                        )
                    }
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        transactionControllers.forEach { controller in
            controller.stopBLEScan()
            controller.stopTimer()
        }
    }
    
    override func setListeners() {
        dataController.dataSource = dataSource
        contextView.assetsCollectionView.dataSource = dataSource
        contextView.assetsCollectionView.delegate = listLayout
        contextView.setSearchInputDelegate(self)
        setListLayoutListeners()
    }
    
    private func setListLayoutListeners() {
        listLayout.handlers.willDisplay = {
            [weak self] cell, indexPath in
            guard let self = self,
                  let itemIdentifier = self.dataSource.itemIdentifier(for: indexPath),
                  let asset = self.dataController[indexPath.item] else {
                return
            }
            
            switch itemIdentifier {
            case .asset:
                let assetCell = cell as! OptOutAssetListItemCell
                assetCell.startObserving(event: .remove) {
                    [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.showAlertToDelete(asset)
                }
            default:
                break
            }
        }

        listLayout.handlers.didSelect = {
            [weak self] indexPath in
            guard let self = self else {
                return
            }

            guard case .asset(let item) = self.dataSource.itemIdentifier(for: indexPath) else { return }

            self.openAssetDetail(
                item.model,
                at: indexPath
            )
        }
    }

    override func prepareLayout() {
        contextView.customize(theme.contextViewTheme)
        
        view.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ManageAssetsViewController {
    private func configureAccessory(
        _ cell: OptOutAssetListItemCell?,
        for item: OptOutAssetListItem
    ) {
        let asset = item.model
        let status = dataController.hasOptedOut(asset)

        let accessory: OptOutAssetListItemAccessory
        switch status {
        case .pending: accessory = .loading
        case .rejected: accessory = .remove
        case .optedOut: accessory = .loading
        }

        cell?.accessory = accessory
    }
}

extension ManageAssetsViewController {
    private func openAssetDetail(
        _ asset: Asset,
        at indexPath: IndexPath
    ) {
        let cell = contextView.assetsCollectionView.cellForItem(at: indexPath)
        let optOutCell = cell as? OptOutAssetListItemCell

        if let collectibleAsset = asset as? CollectibleAsset {
            openCollectibleDetail(
                collectibleAsset,
                from: optOutCell
            )
            return
        }

        let assetDecoration = AssetDecoration(asset: asset)

        openASADiscovery(
            assetDecoration,
            from: optOutCell
        )
    }

    private func openCollectibleDetail(
        _ asset: CollectibleAsset,
        from cell: OptOutAssetListItemCell? = nil
    ) {
        let screen = Screen.collectibleDetail(
            asset: asset,
            account: account,
            thumbnailImage: nil,
            quickAction: .optOut
        ) { event in
            switch event {
            case .didOptOutAssetFromAccount: break
            case .didOptOutFromAssetWithQuickAction:
                cell?.accessory = .loading
            case .didOptInToAsset: break
            }
        }

        open(
            screen,
            by: .push
        )
    }

    private func openASADiscovery(
        _ asset: AssetDecoration,
        from cell: OptOutAssetListItemCell? = nil
    ) {
        let screen = Screen.asaDiscovery(
            account: account,
            quickAction: .optOut,
            asset: asset
        ) { event in
            switch event {
            case .didOptInToAsset: break
            case .didOptOutFromAsset:
                cell?.accessory = .loading
            }
        }
        open(
            screen,
            by: .push
        )
    }
}

extension ManageAssetsViewController {
    private func createNewTransactionController(
        for asset: Asset
    ) -> TransactionController {
        let transactionController = TransactionController(
            api: api!,
            bannerController: bannerController,
            analytics: analytics
        )
        optOutTransactions[asset.id] = AssetOptOutTransaction(
            asset: asset,
            transactionController: transactionController
        )
        transactionController.delegate = self
        return transactionController
    }

    private func clearTransactionCache(
        _ transactionController: TransactionController
    ) {
        if let assetID = getAssetID(from: transactionController) {
            optOutTransactions[assetID] = nil
        }
    }

    private func getAssetID(
        from transactionController: TransactionController
    ) -> AssetID? {
        return transactionController.assetTransactionDraft?.assetIndex
    }

    private func findCell(
        from asset: Asset
    ) -> OptOutAssetListItemCell?  {
        let assetItem = AssetItem(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        let optOutAssetListItem = OptOutAssetListItem(item: assetItem)
        let listItem = ManageAssetSearchItem.asset(optOutAssetListItem)
        let indexPath = dataSource.indexPath(for: listItem)

        return indexPath.unwrap {
            contextView.assetsCollectionView.cellForItem(at: $0)
        } as? OptOutAssetListItemCell
    }

    private func restoreCellState(
        for transactionController: TransactionController
    ) {
        if let assetID = getAssetID(from: transactionController),
           let assetDetail = optOutTransactions[assetID]?.asset,
           let cell = findCell(from: assetDetail) {
            cell.accessory = .remove
        }
    }
}

extension ManageAssetsViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }
        
        if query.isEmpty {
            dataController.resetSearch()
            return
        }
        
        dataController.search(for: query)
    }
    
    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension ManageAssetsViewController {
    private func showAlertToDelete(_ asset: Asset) {
        if isValidAssetDeletion(asset) {
            openOptOutAsset(asset: asset)
            return
        }

        openTransferAssetBalance(asset: asset)
    }
}

extension ManageAssetsViewController {
    private func openOptOutAsset(
        asset: Asset
    ) {
        let draft = OptOutAssetDraft(
            account: account,
            asset: asset
        )

        let screen = Screen.optOutAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove:
                self.continueToOptOutAsset(
                    asset: asset,
                    account: self.account
                )
            case .performClose:
                self.cancelOptOutAsset()
            }
        }

        transitionToOptOutAsset.perform(
            screen,
            by: .present
        )
    }

    private func continueToOptOutAsset(
        asset: Asset,
        account: Account
    ) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            self.removeAssetFromAccount(asset)
        }
    }

    private func cancelOptOutAsset() {
        dismiss(animated: true)
    }
}

extension ManageAssetsViewController {
    private func openTransferAssetBalance(
        asset: Asset
    ) {
        let draft = TransferAssetBalanceDraft(
            account: account,
            asset: asset
        )

        let screen = Screen.transferAssetBalance(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove:
                self.continueToTransferAssetBalance(
                    asset: asset,
                    account: self.account
                )
            case .performClose:
                self.cancelTransferAssetBalance()
            }
        }

        transitionToTransferAssetBalance.perform(
            screen,
            by: .present
        )
    }

    private func continueToTransferAssetBalance(
        asset: Asset,
        account: Account
    ) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            var draft = SendTransactionDraft(
                from: account,
                transactionMode: .asset(asset)
            )
            draft.amount = asset.amountWithFraction

            self.open(
                .sendTransaction(draft: draft),
                by: .push
            )
        }
    }

    private func cancelTransferAssetBalance() {
        dismiss(animated: true)
    }
}

extension ManageAssetsViewController {
    private func isValidAssetDeletion(_ asset: Asset) -> Bool {
        return asset.amountWithFraction == 0
    }
    
    private func removeAssetFromAccount(_ asset: Asset) {
        var account = dataController.account

        if !canSignTransaction(for: &account) {
            return
        }

        guard let creator = asset.creator else {
            return
        }

        let monitor = self.sharedDataController.blockchainUpdatesMonitor
        let request = OptOutBlockchainRequest(asset: asset)
        monitor.startMonitoringOptOutUpdates(
            request,
            for: account
        )

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            toAccount: Account(address: creator.address, type: .standard),
            amount: 0,
            assetIndex: asset.id,
            assetCreator: creator.address
        )
        let transactionController = createNewTransactionController(for: asset)
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetRemoval)
        
        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension ManageAssetsViewController: TransactionControllerDelegate {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        guard let assetID = getAssetID(from: transactionController),
              let asset = optOutTransactions[assetID]?.asset else {
            return
        }

        if let standardAsset = asset as? StandardAsset {
            delegate?.manageAssetsViewController(self, didRemove: standardAsset)
        } else if let collectibleAsset = asset as? CollectibleAsset {
            delegate?.manageAssetsViewController(self, didRemove: collectibleAsset)
        }

        clearTransactionCache(transactionController)
    }
    
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }

        finishMonitoringOptOutUpdates(for: transactionController)
        restoreCellState(for: transactionController)
        clearTransactionCache(transactionController)
    }
    
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amountText.someString
                )
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            let bottomTransition = BottomSheetTransition(presentingViewController: self)

            bottomTransition.perform(
                .bottomWarning(
                    configurator: BottomWarningViewConfigurator(
                        image: "icon-info-green".uiImage,
                        title: "ledger-pairing-issue-error-title".localized,
                        description: .plain("ble-error-fail-ble-connection-repairing".localized),
                        secondaryActionButtonTitle: "title-ok".localized
                    )
                ),
                by: .presentWithoutNavigationController
            )
        default:
            break
        }
    }
    
    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.debugDescription
            )
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }

        finishMonitoringOptOutUpdates(for: transactionController)
        restoreCellState(for: transactionController)
        clearTransactionCache(transactionController)
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: self)
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
    }
    
    private func getRemovedAssetDetail(from draft: AssetTransactionSendDraft?) -> Asset? {
        return draft?.assetIndex.unwrap { account[$0] }
    }
}

extension ManageAssetsViewController {
    private func finishMonitoringOptOutUpdates(for transactionController: TransactionController) {
        if let assetID = getAssetID(from: transactionController) {
            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let account = dataController.account
            monitor.finishMonitoringOptOutUpdates(
                forAssetID: assetID,
                for: account
            )
        }
    }
}

protocol ManageAssetsViewControllerDelegate: AnyObject {
    func manageAssetsViewController(
        _ manageAssetsViewController: ManageAssetsViewController,
        didRemove asset: StandardAsset
    )
    func manageAssetsViewController(
        _ manageAssetsViewController: ManageAssetsViewController,
        didRemove asset: CollectibleAsset
    )
}

struct AssetOptOutTransaction: Equatable {
    let asset: Asset
    let transactionController: TransactionController

    static func == (
        lhs: AssetOptOutTransaction,
        rhs: AssetOptOutTransaction
    ) -> Bool {
        return lhs.asset.id == rhs.asset.id
    }
}
