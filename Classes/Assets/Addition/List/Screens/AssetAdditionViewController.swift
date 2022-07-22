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
//  AssetAdditionViewController.swift

import UIKit
import MagpieHipo
import MagpieExceptions

final class AssetAdditionViewController: BaseViewController, TestNetTitleDisplayable {
    weak var delegate: AssetAdditionViewControllerDelegate?

    private lazy var theme = Theme()

    private lazy var assetActionConfirmationTransition = BottomSheetTransition(presentingViewController: self)
    private var account: Account

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api, bannerController: bannerController)
    }()

    private lazy var dataSource = AssetListViewDataSource(assetListView.collectionView)
    private lazy var dataController = AssetListViewAPIDataController(self.api!)
    private lazy var listLayout = AssetListViewLayout(listDataSource: dataSource)

    private lazy var assetSearchInput = SearchInputView()
    private lazy var assetListView = AssetListView()

    private lazy var currencyFormatter = CurrencyFormatter()

    private var currentAsset: AssetDecoration?

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        addBarButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        transactionController.stopTimer()
    }
    
    override func configureAppearance() {
        super.configureAppearance()

        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "title-add-asset".localized
    }

    override func prepareLayout() {
        super.prepareLayout()

        addAssetSearchInput()
        addAssetList()
    }

    override func linkInteractors() {
        super.linkInteractors()

        assetSearchInput.delegate = self
        transactionController.delegate = self
        assetListView.collectionView.delegate = listLayout
        assetListView.collectionView.dataSource = dataSource
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(
                    snapshot,
                    animatingDifferences: self.isViewAppeared
                )
            }
        }

        dataController.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        assetListView.collectionView.visibleCells.forEach {
            let loadingCell = $0 as? PreviewLoadingCell
            loadingCell?.startAnimating()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        assetListView.collectionView.visibleCells.forEach {
            let loadingCell = $0 as? PreviewLoadingCell
            loadingCell?.stopAnimating()
        }
    }

    override func setListeners() {
        super.setListeners()

        listLayout.handlers.willDisplay = {
            [weak self] cell, indexPath in
            guard let self = self else {
                return
            }

            self.dataController.loadNextPageIfNeeded(for: indexPath)
        }

        listLayout.handlers.didSelectAssetAt = {
            [weak self] indexPath in
            guard let self = self,
                  let asset = self.dataController.assets[safe: indexPath.item] else {
                return
            }

            self.openAssetConfirmation(for: asset)
        }
    }
}

extension AssetAdditionViewController {
    private func addBarButtons() {
        let infoBarButton = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.open(.verifiedAssetInformation, by: .present)
        }

        rightBarButtonItems = [infoBarButton]
    }
}

extension AssetAdditionViewController {
    private func addAssetSearchInput() {
        assetSearchInput.customize(theme.searchInputViewTheme)
        view.addSubview(assetSearchInput)
        assetSearchInput.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.searchInputTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.searchInputHorizontalPadding)
        }
    }

    private func addAssetList() {
        assetListView.customize(AssetListViewTheme())
        view.addSubview(assetListView)
        assetListView.snp.makeConstraints {
            $0.top.equalTo(assetSearchInput.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AssetAdditionViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        let query = view.text
        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension AssetAdditionViewController:
    AssetActionConfirmationViewControllerDelegate,
    TransactionSignChecking {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        if !canSignTransaction(for: &account) {
            return
        }
        
        let assetTransactionDraft = AssetTransactionSendDraft(from: account, assetIndex: asset.id)
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)

        loadingController?.startLoadingWithMessage("title-loading".localized)
        
        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }

        currentAsset = asset
    }
}

extension AssetAdditionViewController {
    private func openAssetConfirmation(for asset: AssetDecoration) {
        if account.containsAsset(asset.id) {
            displaySimpleAlertWith(title: "asset-you-already-own-message".localized, message: "")
            return
        }

        let assetAlertDraft = AssetAlertDraft(
            account: account,
            assetId: asset.id,
            asset: asset,
            transactionFee: Transaction.Constant.minimumFee,
            title: "asset-add-confirmation-title".localized,
            detail: "asset-add-warning".localized,
            actionTitle: "title-approve".localized,
            cancelTitle: "title-cancel".localized
        )

        assetActionConfirmationTransition.perform(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: self),
            by: .presentWithoutNavigationController
        )
    }
}

extension AssetAdditionViewController: TransactionControllerDelegate {
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

        guard let assetDetail = currentAsset else {
            return
        }

        if assetDetail.isCollectible {
            let collectibleAsset = CollectibleAsset(
                asset: ALGAsset(id: assetDetail.id),
                decoration: assetDetail
            )

            NotificationCenter.default.post(
                name: CollectibleListLocalDataController.didAddCollectible,
                object: self,
                userInfo: [
                    CollectibleListLocalDataController.accountAssetPairUserInfoKey: (account, collectibleAsset)
                ]
            )
        } else {
            delegate?.assetAdditionViewController(self, didAdd: assetDetail)
        }

        popScreen()
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

protocol AssetAdditionViewControllerDelegate: AnyObject {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd asset: AssetDecoration
    )
}
