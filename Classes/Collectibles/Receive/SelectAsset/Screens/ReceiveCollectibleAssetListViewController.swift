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

//   ReceiveCollectibleAssetListViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonUtils

final class ReceiveCollectibleAssetListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    NotificationObserver,
    UIContextMenuInteractionDelegate {
    var notificationObservations: [NSObjectProtocol] = []

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = ReceiveCollectibleAssetListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var selectedAccountPreviewCanvasView = MacaroonUIKit.BaseView()
    private lazy var selectedAccountPreviewView = SelectedAccountPreviewView()

    private lazy var transitionToOptInAsset = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private lazy var listLayout = ReceiveCollectibleAssetListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = ReceiveCollectibleAssetListDataSource(listView)

    private var isLayoutFinalized = false

    private var optInTransactions: [AssetID: AssetOptInTransaction] = [:]

    private var transactionControllers: [TransactionController] {
        return Array(optInTransactions.values.map { $0.transactionController })
    }

    private lazy var accountMenuInteraction = UIContextMenuInteraction(delegate: self)

    private lazy var currencyFormatter = CurrencyFormatter()

    private let copyToClipboardController: CopyToClipboardController

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private let dataController: ReceiveCollectibleAssetListDataController
    private let theme: ReceiveCollectibleAssetListViewControllerTheme

    init(
        dataController: ReceiveCollectibleAssetListDataController,
        theme: ReceiveCollectibleAssetListViewControllerTheme = .init(),
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.theme = theme
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    deinit {
        stopObservingNotifications()
    }

    override func configureNavigationBarAppearance() {
        navigationItem.title = String(localized: "collectibles-receive-asset-title")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdateAccount:
                self.configureAccessoryOfVisibleCells()
            case .didUpdateAssets(let snapshot):
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }

        dataController.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartLoadingOfVisibleCellsIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        transactionControllers.forEach { controller in
            controller.stopBLEScan()
            controller.stopTimer()
            cancelMonitoringOptInUpdates(for: controller)
            restoreCellState(for: controller)
            clearTransactionCache(controller)
        }
    }

    override func prepareLayout() {
        super.prepareLayout()
        build()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self

        selectedAccountPreviewView.startObserving(event: .performCopyAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.copyAddress()
        }

        selectedAccountPreviewView.startObserving(event: .performQRAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.openQRGenerator()
        }

        observeWhenKeyboardWillShow {
            [weak self] notification in
            guard let self else { return }
            self.didReceive(keyboardWillShow: notification)
        }

        observeWhenKeyboardWillHide {
            [weak self] notification in
            guard let self  else { return }
            self.didReceive(keyboardWillHide: notification)
        }
    }

    override func linkInteractors() {
        selectedAccountPreviewView.addInteraction(accountMenuInteraction)

        selectedAccountPreviewView.startObserving(event: .performCopyAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.copyAddress()
        }

        selectedAccountPreviewView.startObserving(event: .performQRAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.openQRGenerator()
        }
    }

    override func bindData() {
        selectedAccountPreviewView.bindData(
            SelectedAccountPreviewViewModel(
                IconWithShortAddressDraft(
                    dataController.account
                )
            )
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isLayoutFinalized {
            isLayoutFinalized = true
            listLayout.selectedAccountPreviewCanvasViewHeight = selectedAccountPreviewCanvasView.frame.height
        }
    }

    private func build() {
        addBackground()
        addListView()
        addSelectedAccountPreviewView()
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func addBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addSelectedAccountPreviewView() {
        selectedAccountPreviewCanvasView.backgroundColor = theme.backgroundColor.uiColor

        view.addSubview(selectedAccountPreviewCanvasView)
        selectedAccountPreviewCanvasView.snp.makeConstraints {
            $0.setPaddings((.noMetric, 0, 0, 0))
        }

        selectedAccountPreviewView.customize(
            SelectedAccountPreviewViewTheme()
        )

        selectedAccountPreviewCanvasView.addSubview(selectedAccountPreviewView)
        selectedAccountPreviewView.snp.makeConstraints {
            $0.bottom == view.safeAreaBottom

            $0.setPaddings((0, 0, .noMetric, 0))
        }
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func copyAddress() {
        let account = dataController.account
        copyToClipboardController.copyAddress(account)
    }

    private func openQRGenerator() {
        let account = dataController.account
        
        let draft = QRCreationDraft(
            address: account.address,
            mode: .address,
            title: account.name
        )

        open(
            .qrGenerator(
                title: account.primaryDisplayName,
                draft: draft,
                isTrackable: true
            ),
            by: .present
        )
    }
}

extension ReceiveCollectibleAssetListViewController {
     func contextMenuInteraction(
         _ interaction: UIContextMenuInteraction,
         configurationForMenuAtLocation location: CGPoint
     ) -> UIContextMenuConfiguration? {
         return UIContextMenuConfiguration { _ in
             let copyActionItem = UIAction(item: .copyAddress) {
                 [unowned self] _ in
                 let account = self.dataController.account
                 self.copyToClipboardController.copyAddress(account)
             }
             return UIMenu(children: [ copyActionItem ])
         }
     }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
 }

extension ReceiveCollectibleAssetListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension ReceiveCollectibleAssetListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? CollectibleListItemLoadingCell
                loadingCell?.startAnimating()
            default:
                break
            }
        case .search:
            linkInteractors(cell as! CollectibleReceiveSearchInputCell)
        case .collectible(let item):
            configureAccessory(
                cell as? OptInAssetListItemCell,
                for: item
            )
            linkInteractors(
                cell as? OptInAssetListItemCell,
                for: item
            )

            dataController.loadNextPageIfNeeded(for: indexPath)
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? CollectibleListItemLoadingCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
}

extension ReceiveCollectibleAssetListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        view.endEditing(true)

        guard case .collectible(let item) = listDataSource.itemIdentifier(for: indexPath) else { return }

        let asset = item.model
        let cell = collectionView.cellForItem(at: indexPath)
        let optInCell = cell as? OptInAssetListItemCell
        openCollectibleDetail(
            asset,
            from: optInCell
        )
    }

    private func openCollectibleDetail(
        _ asset: AssetDecoration,
        from cell: OptInAssetListItemCell? = nil
    ) {
        let account = dataController.account
        let collectibleAsset = CollectibleAsset(
            asset: ALGAsset(id: asset.id),
            decoration: asset
        )
        let screen = Screen.collectibleDetail(
            asset: collectibleAsset,
            account: account,
            quickAction: .optIn
        ) { event in
            switch event {
            case .didOptOutAssetFromAccount: break
            case .didOptOutFromAssetWithQuickAction: break
            case .didOptInToAsset:
                cell?.accessory = .loading
            }
        }
        open(
            screen,
            by: .push
        )
    }

    private func continueToOptInAsset(asset: AssetDecoration) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            let account = self.dataController.account
            let transactionController = self.createNewTransactionController(for: asset)
            
            if !transactionController.canSignTransaction(for: account) {
                self.clearTransactionCache(transactionController)
                self.restoreCellState(for: transactionController)
                return
            }

            let monitor = self.sharedDataController.blockchainUpdatesMonitor
            let request = OptInBlockchainRequest(account: account, asset: asset)
            monitor.startMonitoringOptInUpdates(request)

            let assetTransactionDraft = AssetTransactionSendDraft(
                from: account,
                assetIndex: asset.id
            )
            transactionController.setTransactionDraft(assetTransactionDraft)
            transactionController.getTransactionParamsAndComposeTransactionData(for: .optIn)

            if account.requiresLedgerConnection() {
                self.openLedgerConnection(transactionController)

                transactionController.initializeLedgerTransactionAccount()
                transactionController.startTimer()
            }
        }
    }

    private func cancelOptInAsset() {
        dismiss(animated: true)
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func configureAccessoryOfVisibleCells() {
        listView.indexPathsForVisibleItems.forEach {
            indexPath in
            guard let listItem = listDataSource.itemIdentifier(for: indexPath) else { return }
            guard case let ReceiveCollectibleAssetListItem.collectible(item) = listItem else { return }

            let cell = listView.cellForItem(at: indexPath) as? OptInAssetListItemCell
            configureAccessory(
                cell,
                for: item
            )
        }
    }

    private func configureAccessory(
        _ cell: OptInAssetListItemCell?,
        for item: OptInAssetListItem
    ) {
        let asset = item.model
        let status = dataController.hasOptedIn(asset)

        let accessory: OptInAssetListItemAccessory
        switch status {
        case .pending: accessory = .loading
        case .optedIn: accessory = .check
        case .rejected: accessory = .add
        }

        cell?.accessory = accessory
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func linkInteractors(
        _ cell: CollectibleReceiveSearchInputCell
    ) {
        cell.delegate = self
    }

    private func linkInteractors(
        _ cell: OptInAssetListItemCell?,
        for item: OptInAssetListItem
    ) {
        cell?.startObserving(event: .add) {
            [unowned self] in

            let account = self.dataController.account
            let asset = item.model
            let draft = OptInAssetDraft(account: account, asset: asset)
            let screen = Screen.optInAsset(draft: draft) {
                [weak self, weak cell] event in
                guard let self = self else { return }

                switch event {
                case .performApprove:
                    cell?.accessory = .loading
                    self.continueToOptInAsset(asset: asset)
                case .performClose:
                    self.cancelOptInAsset()
                }
            }
            self.transitionToOptInAsset.perform(
                screen,
                by: .present
            )
        }
    }
}

extension ReceiveCollectibleAssetListViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }

        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func restartLoadingOfVisibleCellsIfNeeded() {
        for cell in listView.visibleCells {
            if let assetCell = cell as? OptInAssetListItemCell,
               assetCell.accessory == .loading {
                assetCell.accessory = .loading
            } else if let loadingCell = cell as? CollectibleListItemLoadingCell {
                loadingCell.startAnimating()
            }
        }
    }
}

extension ReceiveCollectibleAssetListViewController: TransactionControllerDelegate {
    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        cancelMonitoringOptInUpdates(for: transactionController)
        restoreCellState(for: transactionController)
        clearTransactionCache(transactionController)

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        cancelMonitoringOptInUpdates(for: transactionController)
        restoreCellState(for: transactionController)
        clearTransactionCache(transactionController)

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: error.localizedDescription)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        NotificationCenter.default.post(
            name: CollectibleListLocalDataController.didAddCollectible,
            object: self
        )

        clearTransactionCache(transactionController)
    }

    private func displayTransactionError(
        from transactionError: TransactionError
    ) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: String(localized: "asset-min-transaction-error-title"),
                message: String(format: String(localized: "asset-min-transaction-error-message"), amountText.someString)
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: String(localized: "send-algos-receiver-address-validation")
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: String(localized: "title-error"),
                message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

                self.openLedgerConnectionIssues()
            }
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        ledgerConnectionScreen?.dismiss(animated: true) {
            self.ledgerConnectionScreen = nil

            self.openSignWithLedgerProcess(
                transactionController: transactionController,
                ledgerDeviceName: ledger
            )
        }
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismiss(animated: true)
        signWithLedgerProcessScreen = nil

        cancelMonitoringOptInUpdates(for: transactionController)
        restoreCellState(for: transactionController)
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
    }

    private func cancelMonitoringOptInUpdates(for transactionController: TransactionController) {
        if let assetID = getAssetID(from: transactionController) {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            let account = dataController.account
            monitor.cancelMonitoringOptInUpdates(
                forAssetID: assetID,
                for: account
            )
        }
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func openLedgerConnection(_ transactionController: TransactionController) {
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                transactionController.stopBLEScan()
                transactionController.stopTimer()
                self.cancelMonitoringOptInUpdates(for: transactionController)
                self.restoreCellState(for: transactionController)
                self.clearTransactionCache(transactionController)

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.loadingController?.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func openLedgerConnectionIssues() {
        transitionToLedgerConnectionIssuesWarning.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-info-green".uiImage,
                    title: String(localized: "ledger-pairing-issue-error-title"),
                    description: .plain(String(localized: "ble-error-fail-ble-connection-repairing")),
                    secondaryActionButtonTitle: String(localized: "title-ok")
                )
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: 1
        )
        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .performCancelApproval:
                transactionController.stopBLEScan()
                transactionController.stopTimer()

                self.signWithLedgerProcessScreen?.dismissScreen()
                self.signWithLedgerProcessScreen = nil

                self.cancelMonitoringOptInUpdates(for: transactionController)
                self.restoreCellState(for: transactionController)
                self.clearTransactionCache(transactionController)
            }
        }
        signWithLedgerProcessScreen = transitionToSignWithLedgerProcess.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func createNewTransactionController(
        for asset: AssetDecoration
    ) -> TransactionController {
        let transactionController = TransactionController(
            api: api!,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics,
            hdWalletStorage: hdWalletStorage
        )
        optInTransactions[asset.id] = AssetOptInTransaction(
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
            optInTransactions[assetID] = nil
        }
    }

    private func getAssetID(
        from transactionController: TransactionController
    ) -> AssetID? {
        return transactionController.assetTransactionDraft?.assetIndex
    }

    private func findCell(
        from asset: AssetDecoration
    ) -> OptInAssetListItemCell?  {
        let item = ReceiveCollectibleAssetListItem.collectible(OptInAssetListItem(asset: asset))
        let indexPath = listDataSource.indexPath(for: item)
        return indexPath.unwrap {
            listView.cellForItem(at: $0)
        } as? OptInAssetListItemCell
    }

    private func restoreCellState(
        for transactionController: TransactionController
    ) {
        if let assetID = getAssetID(from: transactionController),
           let assetDetail = optInTransactions[assetID]?.asset,
           let cell = findCell(from: assetDetail) {
            cell.accessory = .add
        }
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func updateLayoutWhenKeyboardHeightDidChange(
        _ keyboardHeight: LayoutMetric = 0,
        isShowing: Bool
    ) {
        if isShowing {
            selectedAccountPreviewCanvasView.snp.updateConstraints {
                $0.bottom == keyboardHeight
            }

            selectedAccountPreviewView.snp.updateConstraints {
                $0.bottom == 0
            }
        } else {
            selectedAccountPreviewCanvasView.snp.updateConstraints {
                $0.bottom == 0
            }

            selectedAccountPreviewView.snp.updateConstraints {
                $0.bottom == view.safeAreaBottom
            }
        }

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: UIView.AnimationOptions(
                rawValue: UInt(UIView.AnimationCurve.linear.rawValue >> 16)
            ),
            animations: {
                [weak self] in
                guard let self = self else { return }
                self.view.layoutIfNeeded()
            }
        )
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func didReceive(
        keyboardWillShow notification: Notification
    ) {
        guard UIApplication.shared.isActive,
              let keyboardHeight = notification.keyboardHeight else {
                  return
              }

        updateLayoutWhenKeyboardHeightDidChange(
            keyboardHeight,
            isShowing: true
        )
    }

    private func didReceive(
        keyboardWillHide notification: Notification
    ) {
        guard UIApplication.shared.isActive else {
            return
        }

        updateLayoutWhenKeyboardHeightDidChange(isShowing: false)
    }
}
