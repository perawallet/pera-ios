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

final class ManageAssetsViewController: BaseViewController {
    weak var delegate: ManageAssetsViewControllerDelegate?

    private lazy var theme = Theme()

    private lazy var assetActionConfirmationTransition = BottomSheetTransition(presentingViewController: self)
    
    private lazy var contextView = ManageAssetsView()
    
    private var account: Account
    private var listItems: [Asset]
    private var accountAssets: [Asset] = []

    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api, bannerController: bannerController)
    }()

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        self.listItems = account.allAssets
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }
    
    override func linkInteractors() {
        contextView.assetsCollectionView.delegate = self
        contextView.assetsCollectionView.dataSource = self
        contextView.setSearchInputDelegate(self)
        transactionController.delegate = self
    }
    
    override func prepareLayout() {
        contextView.customize(theme.contextViewTheme)
        
        view.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssets()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        transactionController.stopTimer()
    }
    
    override func configureAppearance() {
        contextView.updateContentStateView()
    }
}

extension ManageAssetsViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }
}

extension ManageAssetsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = listItems[safe: indexPath.item] else {
            fatalError("Not found asset.")
        }

        let cell = collectionView.dequeue(AssetPreviewDeleteCell.self, at: indexPath)

        let viewModel: AssetPreviewViewModel

        if let collectibleAsset = asset as? CollectibleAsset {
            viewModel = AssetPreviewViewModel(collectibleAsset)
        } else {
            let assetPreviewModel = AssetPreviewModelAdapter.adapt((asset))
            viewModel = AssetPreviewViewModel(assetPreviewModel)
        }

        cell.bindData(viewModel)
        cell.delegate = self

        return cell
    }
}

extension ManageAssetsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
}

extension ManageAssetsViewController {
    private func fetchAssets() {
        accountAssets.removeAll()
        
        account.allAssets.forEach {
            if !$0.state.isPending {
                accountAssets.append($0)
            }
        }
        
        loadAssets()
    }

    private func loadAssets() {
        listItems = accountAssets
        reloadAssets()
    }
    
    private func reloadAssets() {
        contextView.assetsCollectionView.reloadData()
        contextView.updateContentStateView()
    }

    private func filterData(with query: String) { 
        listItems = account.allAssets.filter { asset in
            isAssetContainsID(asset, query: query) ||
            isAssetContainsName(asset, query: query) ||
            isAssetContainsUnitName(asset, query: query)
        }

        reloadAssets()
    }

    private func isAssetContainsID(_ asset: Asset, query: String) -> Bool {
        return String(asset.presentation.id).localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsName(_ asset: Asset, query: String) -> Bool {
        return asset.presentation.name.someString.localizedCaseInsensitiveContains(query)
    }

    private func isAssetContainsUnitName(_ asset: Asset, query: String) -> Bool {
        return asset.presentation.unitName.someString.localizedCaseInsensitiveContains(query)
    }
}

extension ManageAssetsViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text,
              !query.isEmpty else {
                  fetchAssets()
                  return
        }
        filterData(with: query)
    }
    
    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension ManageAssetsViewController: AssetPreviewDeleteCellDelegate {
    func assetPreviewDeleteCellDidDelete(_ assetPreviewDeleteCell: AssetPreviewDeleteCell) {
        guard let indexPath = contextView.assetsCollectionView.indexPath(for: assetPreviewDeleteCell),
              let asset = listItems[safe: indexPath.item] else {
                  return
        }
        
        showAlertToDelete(asset)
    }
    
    private func showAlertToDelete(_ asset: Asset) {
        let assetDecoration = AssetDecoration(asset: asset)
        
        let assetAlertDraft: AssetAlertDraft

        if isValidAssetDeletion(asset) {
            assetAlertDraft = AssetAlertDraft(
                account: account,
                assetId: assetDecoration.id,
                asset: assetDecoration,
                title: "asset-remove-confirmation-title".localized,
                detail: String(
                    format: "asset-remove-transaction-warning".localized,
                    "\(assetDecoration.unitName ?? "title-unknown".localized)",
                    "\(account.name ?? "")"
                ),
                actionTitle: "title-remove".localized,
                cancelTitle: "title-keep".localized
            )
        } else {
            assetAlertDraft = AssetAlertDraft(
                account: account,
                assetId: assetDecoration.id,
                asset: assetDecoration,
                title: "asset-remove-confirmation-title".localized,
                detail: String(
                    format: "asset-remove-warning".localized,
                    "\(assetDecoration.unitName ?? "title-unknown".localized)",
                    "\(account.name ?? "")"
                ),
                actionTitle: "asset-transfer-balance".localized,
                cancelTitle: "title-keep".localized
            )
        }
        
        assetActionConfirmationTransition.perform(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: self),
            by: .presentWithoutNavigationController
        )
    }
}

extension ManageAssetsViewController:
    AssetActionConfirmationViewControllerDelegate,
    TransactionSignChecking {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmAction asset: AssetDecoration
    ) {
        if !canSignTransaction(for: &account) {
            return
        }

        guard let asset = account[asset.id] else {
            return
        }
        
        if !isValidAssetDeletion(asset) {
            var draft = SendTransactionDraft(from: account, transactionMode: .asset(asset))
            draft.amount = asset.amountWithFraction
            open(
                .sendTransaction(draft: draft),
                by: .push
            )
            return
        }
        
        removeAssetFromAccount(asset)
    }

    private func isValidAssetDeletion(_ asset: Asset) -> Bool {
        return asset.amountWithFraction == 0
    }
    
    private func removeAssetFromAccount(_ asset: Asset) {
        guard let creator = asset.creator else {
            return
        }

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            toAccount: Account(address: creator.address, type: .standard),
            amount: 0,
            assetIndex: asset.id,
            assetCreator: creator.address
        )
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetRemoval)
        
        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension ManageAssetsViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?) {
        loadingController?.stopLoading()

        guard let assetTransactionDraft = draft as? AssetTransactionSendDraft,
              var removedAssetDetail = getRemovedAssetDetail(from: assetTransactionDraft) else {
                  return
              }

        removedAssetDetail.state = .pending(.remove)

        fetchAssets()
        
        contextView.resetSearchInputView()

        if let standardAsset = removedAssetDetail as? StandardAsset {
            delegate?.manageAssetsViewController(self, didRemove: standardAsset)
        } else if let collectibleAsset = removedAssetDetail as? CollectibleAsset {
            delegate?.manageAssetsViewController(self, didRemove: collectibleAsset)
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        loadingController?.stopLoading()
        
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }
    
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amount.toAlgos.toAlgosStringForLabel ?? ""
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
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        loadingController?.stopLoading()
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
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
    
    private func getRemovedAssetDetail(from draft: AssetTransactionSendDraft?) -> Asset? {
        return draft?.assetIndex.unwrap { account[$0] }
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
