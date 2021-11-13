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
//  ManageAssetsViewController.swift

import UIKit
import Magpie

final class ManageAssetsViewController: BaseViewController {
    weak var delegate: ManageAssetsViewControllerDelegate?

    private lazy var theme = Theme()

    private lazy var assetActionConfirmationPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(theme.assetActionConfirmationModalSize))
    )
    
    private lazy var manageAssetsView = ManageAssetsView()
    
    private var account: Account
    
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
        manageAssetsView.assetsCollectionView.delegate = self
        manageAssetsView.assetsCollectionView.dataSource = self
        transactionController.delegate = self
    }
    
    override func prepareLayout() {
        view.addSubview(manageAssetsView)
        manageAssetsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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

extension ManageAssetsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return account.assetDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AssetPreviewActionCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.customize(theme.assetPreviewActionViewTheme)
        cell.bindData(AssetPreviewViewModel(AssetPreviewModelAdapter.adapt(account.assetDetails[indexPath.item])))
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

extension ManageAssetsViewController: AssetPreviewActionCellDelegate {
    func assetPreviewSendCellDidTapSendButton(_ assetPreviewSendCell: AssetPreviewActionCell) {
        guard let index = manageAssetsView.assetsCollectionView.indexPath(for: assetPreviewSendCell),
              index.item < account.assetDetails.count else {
                  return
              }

        let assetDetail = account.assetDetails[index.item]
        guard let assetAmount = account.amount(for: assetDetail) else {
            return
        }

        let assetAlertDraft: AssetAlertDraft

        if assetAmount == 0 {
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
        } else {
            assetAlertDraft = AssetAlertDraft(
                account: account,
                assetIndex: assetDetail.id,
                assetDetail: assetDetail,
                title: "asset-remove-confirmation-title".localized,
                detail: String(
                    format: "asset-remove-warning".localized,
                    "\(assetDetail.unitName ?? "title-unknown".localized)",
                    "\(account.name ?? "")"
                ),
                actionTitle: "asset-transfer-balance".localized,
                cancelTitle: "title-keep".localized
            )
        }

        let controller = open(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: assetActionConfirmationPresenter
            )
        ) as? AssetActionConfirmationViewController

        controller?.delegate = self
    }
}

extension ManageAssetsViewController: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    ) {
        guard let session = session,
              session.canSignTransaction(for: &account) else {
                  return
              }
        
        if let assetAmount = account.amount(for: assetDetail),
           assetAmount != 0 {
            let controller = open(
                .sendAssetTransactionPreview(
                    account: account,
                    receiver: .initial,
                    assetDetail: assetDetail,
                    isSenderEditable: false,
                    isMaxTransaction: true
                ),
                by: .push
            )
            (controller as? SendAssetTransactionPreviewViewController)?.delegate = self
            return
        }
        
        removeAssetFromAccount(assetDetail)
    }
    
    private func removeAssetFromAccount(_ assetDetail: AssetDetail) {
        let assetTransactionDraft = AssetTransactionSendDraft(
            from: account,
            toAccount: assetDetail.creator,
            amount: 0,
            assetIndex: assetDetail.id,
            assetCreator: assetDetail.creator
        )
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetRemoval)
        
        loadingController?.startLoadingWithMessage("title-loading".localized)

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

        removedAssetDetail.isRemoved = true
        delegate?.manageAssetsViewController(self, didRemove: removedAssetDetail, from: account)
        dismissScreen()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPError<TransactionError>) {
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
        default:
            break
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPError<TransactionError>) {
        loadingController?.stopLoading()
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
        }
    }
    
    private func getRemovedAssetDetail(from draft: AssetTransactionSendDraft?) -> AssetDetail? {
        guard let removedAssetDetail = account.assetDetails.first(where: { assetDetail -> Bool in
            guard let assetId = draft?.assetIndex else {
                return false
            }
            return assetDetail.id == assetId
        }) else {
            return nil
        }
        
        return removedAssetDetail
    }
}

extension ManageAssetsViewController: SendAssetTransactionPreviewViewControllerDelegate {
    func sendAssetTransactionPreviewViewController(
        _ viewController: SendAssetTransactionPreviewViewController,
        didCompleteTransactionFor assetDetail: AssetDetail
    ) {
        removeAssetFromAccount(assetDetail)
        delegate?.manageAssetsViewController(self, didRemove: assetDetail, from: account)
        closeScreen(by: .dismiss, animated: false)
    }
}

protocol ManageAssetsViewControllerDelegate: AnyObject {
    func manageAssetsViewController(
        _ manageAssetsViewController: ManageAssetsViewController,
        didRemove assetDetail: AssetDetail,
        from account: Account
    )
}
