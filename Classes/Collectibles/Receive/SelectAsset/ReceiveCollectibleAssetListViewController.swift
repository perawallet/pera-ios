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

//   ReceiveCollectibleAssetListViewController.swift

import UIKit
import MacaroonUIKit

final class ReceiveCollectibleAssetListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
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

    private lazy var bottomSheetTransition = BottomSheetTransition(
        presentingViewController: self
    )

    private lazy var listLayout = ReceiveCollectibleAssetListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = ReceiveCollectibleAssetListDataSource(listView)

    private lazy var transactionController: TransactionController = {
        return TransactionController(
            api: api!,
            bannerController: bannerController
        )
    }()

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    private var currentAsset: AssetDecoration?

    private let account: AccountHandle
    private let dataController: ReceiveCollectibleAssetListDataController
    private let theme: ReceiveCollectibleAssetListViewControllerTheme

    init(
        account: AccountHandle,
        dataController: ReceiveCollectibleAssetListDataController,
        theme: ReceiveCollectibleAssetListViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.dataController = dataController
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        navigationItem.title = "collectibles-receive-action".localized
    }

    override func prepareLayout() {
        super.prepareLayout()
        build()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }

        dataController.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        listView
            .visibleCells
            .forEach {
                let loadingCell = $0 as? PreviewLoadingCell
                loadingCell?.startAnimating()
            }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        listView
            .visibleCells
            .forEach {
                let loadingCell = $0 as? PreviewLoadingCell
                loadingCell?.stopAnimating()
            }
    }

    private func build() {
        addBackground()
        addListView()
    }

    override func linkInteractors() {
        transactionController.delegate = self
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
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
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.startAnimating()
            default:
                break
            }
        case .search:
            linkInteractors(cell as! CollectibleSearchInputCell)
        case .collectible:
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
                let loadingCell = cell as? PreviewLoadingCell
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
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .collectible:
            guard let selectedAsset = dataController[indexPath.item] else {
                return
            }

            if account.value.containsAsset(selectedAsset.id) {
                displaySimpleAlertWith(
                    title: "asset-you-already-own-message".localized,
                    message: .empty
                )
                return
            }

            let assetAlertDraft = AssetAlertDraft(
                account: account.value,
                assetId: selectedAsset.id,
                asset: selectedAsset,
                title: "asset-add-confirmation-title".localized,
                detail: "asset-add-warning".localized,
                actionTitle: "title-approve".localized,
                cancelTitle: "title-cancel".localized
            )

            bottomSheetTransition.perform(
                .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: self),
                by: .presentWithoutNavigationController
            )
        default: break
        }
    }
}

extension ReceiveCollectibleAssetListViewController {
    private func linkInteractors(
        _ cell: CollectibleSearchInputCell
    ) {
        cell.delegate = self
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

extension ReceiveCollectibleAssetListViewController:
    AssetActionConfirmationViewControllerDelegate,
    TransactionSignChecking {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        var anAccount = account.value

        if !canSignTransaction(for: &anAccount) {
            return
        }

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: anAccount,
            assetIndex: asset.id
        )
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

        loadingController?.startLoadingWithMessage("title-loading".localized)

        if anAccount.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }

        currentAsset = asset
    }
}

extension ReceiveCollectibleAssetListViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        loadingController?.stopLoading()
        currentAsset = nil

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }

    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        loadingController?.stopLoading()
        currentAsset = nil

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController?.stopLoading()

        if let currentAsset = currentAsset {
            NotificationCenter.default.post(
                name: CollectibleListLocalDataController.didAddPendingCollectible,
                object: self,
                userInfo: [
                    CollectibleListLocalDataController.assetUserInfoKey: currentAsset
                ]
            )
        }

        dismissScreen()
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(params: amount.toAlgos.toAlgosStringForLabel ?? "")
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
                        description: "ble-error-fail-ble-connection-repairing".localized,
                        secondaryActionButtonTitle: "title-ok".localized
                    )
                ),
                by: .presentWithoutNavigationController
            )
        default:
            break
        }
    }

    func transactionController(_ transactionController: TransactionController, didRequestUserApprovalFrom ledger: String) {
        let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: self)
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(mode: .approve, deviceName: ledger),
            by: .present
        )
    }

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
    }
}
