//
//  AssetRemovalViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Magpie
import CoreBluetooth
import SVProgressHUD

class AssetRemovalViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    private let layoutBuilder = AssetListLayoutBuilder()
    
    private lazy var assetActionConfirmationPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.modalHeight))
    )
    
    private lazy var assetRemovalView = AssetRemovalView()
    
    private var account: Account
    
    private lazy var ledgerApprovalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 354.0))
    )
    
    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api)
    }()
    
    private let viewModel = AssetRemovalViewModel()
    
    private var timer: Timer?
    
    weak var delegate: AssetRemovalViewControllerDelegate?
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        navigationItem.title = "title-remove-assets".localized
    }
    
    override func setListeners() {
        assetRemovalView.assetsCollectionView.delegate = self
        assetRemovalView.assetsCollectionView.dataSource = self
        transactionController.delegate = self
    }
    
    override func prepareLayout() {
        setupAssetRemovalViewLayout()
    }
    
    override func configureNavigationBarAppearance() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.closeScreen(by: .dismiss, animated: true)
        }
        
        rightBarButtonItems = [doneBarButtonItem]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        dismissProgressIfNeeded()
        invalidateTimer()
    }
}

extension AssetRemovalViewController {
    private func setupAssetRemovalViewLayout() {
        view.addSubview(assetRemovalView)
        
        assetRemovalView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetRemovalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return account.assetDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let assetDetail = account.assetDetails[indexPath.item]
        let cell = layoutBuilder.dequeueAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        cell.delegate = self
        viewModel.configure(cell, with: assetDetail)
        return cell
    }
}

extension AssetRemovalViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier,
                for: indexPath
            ) as? AccountHeaderSupplementaryView else {
                fatalError("Unexpected element kind")
            }
            
            viewModel.configure(headerView, with: account)
            
            return headerView
        } else {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AssetRemovalFooterSupplementaryView.reusableIdentifier,
                for: indexPath
            ) as? AssetRemovalFooterSupplementaryView else {
                fatalError("Unexpected element kind")
            }
            
            return headerView
        }
    }
}

extension AssetRemovalViewController: BaseAssetCellDelegate {
    func assetCellDidTapActionButton(_ assetCell: BaseAssetCell) {
        guard let index = assetRemovalView.assetsCollectionView.indexPath(for: assetCell) else {
            return
        }
        
        guard index.item < account.assetDetails.count else {
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
                actionTitle: "title-proceed".localized
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
                actionTitle: "asset-transfer-balance".localized
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

extension AssetRemovalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right
        let assetDetail = account.assetDetails[indexPath.item]
        
        if assetDetail.hasBothDisplayName() {
            return CGSize(width: width, height: layout.current.multiItemHeight)
        } else {
            return CGSize(width: width, height: layout.current.itemHeight)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.itemHeight
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.footerHeight
        )
    }
}

extension AssetRemovalViewController: AssetActionConfirmationViewControllerDelegate {
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
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        validateTimer()
    }
}

extension AssetRemovalViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?) {
        guard let assetTransactionDraft = draft as? AssetTransactionSendDraft,
            let removedAssetDetail = getRemovedAssetDetail(from: assetTransactionDraft) else {
            return
        }
        
        if account.requiresLedgerConnection() {
            ledgerApprovalViewController?.dismissScreen()
        }
        
        delegate?.assetRemovalViewController(self, didRemove: removedAssetDetail, from: account)
        dismissScreen()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) {
        if account.requiresLedgerConnection() {
            ledgerApprovalViewController?.dismissScreen()
        }
        
        SVProgressHUD.dismiss()
        NotificationBanner.showError("title-error".localized, message: error.localizedDescription)
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: Error) {
        if account.requiresLedgerConnection() {
            ledgerApprovalViewController?.dismissScreen()
        }
        
        SVProgressHUD.dismiss()
        NotificationBanner.showError("title-error".localized, message: error.localizedDescription)
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
    
    func transactionControllerDidStartBLEConnection(_ transactionController: TransactionController) {
        dismissProgressIfNeeded()
        invalidateTimer()
        ledgerApprovalViewController = open(
            .ledgerApproval(mode: .approve),
            by: .customPresent(presentationStyle: .custom, transitionStyle: nil, transitioningDelegate: ledgerApprovalPresenter)
        ) as? LedgerApprovalViewController
    }
    
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState) {
        guard let errorTitle = state.errorDescription.title,
            let errorSubtitle = state.errorDescription.subtitle else {
                return
        }
        
        NotificationBanner.showError(errorTitle, message: errorSubtitle)
        invalidateTimer()
        dismissProgressIfNeeded()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral) {
        NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
    }
    
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral) {
    }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
        NotificationBanner.showError(
            "ble-error-transaction-cancelled-title".localized,
            message: "ble-error-fail-sign-transaction".localized
        )
    }
}

extension AssetRemovalViewController {
    func validateTimer() {
        guard account.requiresLedgerConnection() else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                self.transactionController.stopBLEScan()
                self.dismissProgressIfNeeded()
                NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
            }
            
            self.invalidateTimer()
        }
    }
    
    func invalidateTimer() {
        guard account.requiresLedgerConnection() else {
            return
        }
        
        timer?.invalidate()
        timer = nil
    }
}

extension AssetRemovalViewController: SendAssetTransactionPreviewViewControllerDelegate {
    func sendAssetTransactionPreviewViewController(
        _ viewController: SendAssetTransactionPreviewViewController,
        didCompleteTransactionFor assetDetail: AssetDetail
    ) {
        removeAssetFromAccount(assetDetail)
        delegate?.assetRemovalViewController(self, didRemove: assetDetail, from: account)
        closeScreen(by: .dismiss, animated: false)
    }
}

extension AssetRemovalViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultSectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        let itemHeight: CGFloat = 52.0
        let multiItemHeight: CGFloat = 72.0
        let modalHeight: CGFloat = 490.0
        let footerHeight: CGFloat = 10.0
    }
}

protocol AssetRemovalViewControllerDelegate: class {
    func assetRemovalViewController(
        _ assetRemovalViewController: AssetRemovalViewController,
        didRemove assetDetail: AssetDetail,
        from account: Account
    )
}
