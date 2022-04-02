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
    
    private lazy var listLayout = ManageAssetsListLayout()
    private lazy var dataSource = ManageAssetsListDataSource(contextView.assetsCollectionView)
    private lazy var dataController = ManageAssetsListDataController(account, sharedDataController)

    private lazy var assetActionConfirmationTransition = BottomSheetTransition(presentingViewController: self)
    
    private lazy var contextView = ManageAssetsView()
    
    private var account: Account
        
    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api, bannerController: bannerController)
    }()

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }
    
    override func setListeners() {
        contextView.assetsCollectionView.dataSource = dataSource
        contextView.assetsCollectionView.delegate = listLayout
        contextView.setSearchInputDelegate(self)
        transactionController.delegate = self
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
                let assetCell = cell as! AssetPreviewDeleteCell
                assetCell.observe(event: .delete) {
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
        
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(snapshot, animatingDifferences: self.isViewAppeared) {
                    self.contextView.assetsCollectionView.reloadData()
                }
            }
        }
        
        dataController.load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        transactionController.stopBLEScan()
        loadingController?.stopLoading()
        transactionController.stopTimer()
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

extension ManageAssetsViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            dataController.resetSearch()
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
    
    func searchInputViewDidTapRightAccessory(_ view: SearchInputView) {
        dataController.resetSearch()
    }
}

extension ManageAssetsViewController {
    private func showAlertToDelete(_ asset: CompoundAsset) {
        let assetDetail = asset.detail
        let assetAlertDraft: AssetAlertDraft
                
        assetAlertDraft = AssetAlertDraft(
            account: account,
            assetIndex: assetDetail.id,
            assetDetail: assetDetail,
            title: "asset-remove-confirmation-title".localized,
            detail: String(
                format: "asset-remove-transaction-warning".localized,
                "\(assetDetail.unitName ?? "title-unknown".localized)",
                "\(account.name ?? "")"
            ),
            actionTitle: "title-remove".localized,
            cancelTitle: "title-keep".localized
        )
        
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
        didConfirmedActionFor assetDetail: AssetInformation
    ) {
        if !canSignTransaction(for: &account) {
            return
        }
        
        if let assetAmount = account.amount(for: assetDetail),
           assetAmount != 0 {
            var draft = SendTransactionDraft(from: account, transactionMode: .assetDetail(assetDetail))
            draft.amount = assetAmount
            open(
                .sendTransaction(draft: draft),
                by: .push
            )
            return
        }
        
        removeAssetFromAccount(assetDetail)
    }
    
    private func removeAssetFromAccount(_ assetDetail: AssetInformation) {
        guard let creator = assetDetail.creator else {
            return
        }

        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            toAccount: Account(address: creator.address, type: .standard),
            amount: 0,
            assetIndex: assetDetail.id,
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
        guard let assetTransactionDraft = draft as? AssetTransactionSendDraft,
              let removedAssetDetail = getRemovedAssetDetail(from: assetTransactionDraft) else {
                  return
              }
        
        contextView.resetSearchInputView()
        
        delegate?.manageAssetsViewController(self, didRemove: removedAssetDetail, from: account)
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
    
    private func getRemovedAssetDetail(from draft: AssetTransactionSendDraft?) -> AssetInformation? {
        return draft?.assetIndex.unwrap { account[$0]?.detail }
    }
}

protocol ManageAssetsViewControllerDelegate: AnyObject {
    func manageAssetsViewController(
        _ manageAssetsViewController: ManageAssetsViewController,
        didRemove assetDetail: AssetInformation,
        from account: Account
    )
}
