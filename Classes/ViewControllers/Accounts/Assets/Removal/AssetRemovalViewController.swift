//
//  AssetRemovalViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetRemovalViewControllerDelegate: class {
    func assetRemovalViewController(
        _ assetRemovalViewController: AssetRemovalViewController,
        didRemove asset: AssetDetail,
        from account: Account
    )
}

class AssetRemovalViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var assetRemovalView = AssetRemovalView()
    
    private var account: Account
    
    private let viewModel = AssetRemovalViewModel()
    
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
        transactionManager?.delegate = self
    }
    
    override func prepareLayout() {
        setupAssetRemovalViewLayout()
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
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
        if account.assetDetails.isEmpty {
            return 1
        }
        
        return account.assetDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AssetActionableCell.reusableIdentifier,
            for: indexPath) as? AssetActionableCell else {
                fatalError("Index path is out of bounds")
        }
        
        cell.delegate = self
        
        let assetDetail = account.assetDetails[indexPath.item]
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
        if kind != UICollectionView.elementKindSectionHeader {
            fatalError("Unexpected element kind")
        }
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier,
            for: indexPath
        ) as? AccountHeaderSupplementaryView else {
            fatalError("Unexpected element kind")
        }
        
        viewModel.configure(headerView, with: account)
        
        return headerView
    }
}

extension AssetRemovalViewController: AssetActionableCellDelegate {
    func assetActionableCellDidTapActionButton(_ assetActionableCell: AssetActionableCell) {
        guard let index = assetRemovalView.assetsCollectionView.indexPath(for: assetActionableCell) else {
            return
        }
        
        let assetDetail = account.assetDetails[index.item]
        guard let assetIndex = assetDetail.index,
            let asset = account.assets?[assetIndex] else {
                return
        }
        
        let assetAlertDraft: AssetAlertDraft
        
        if asset.amount == 0 {
            assetAlertDraft = AssetAlertDraft(
                account: account,
                assetDetail: assetDetail,
                title: "asset-remove-confirmation-title".localized,
                detail: String(
                    format: "asset-remove-transaction-warning".localized,
                    "\(assetDetail.unitName ?? "")",
                    "\(account.name ?? "")"
                ),
                actionTitle: "title-proceed".localized
            )
        } else {
            assetAlertDraft = AssetAlertDraft(
                account: account,
                assetDetail: assetDetail,
                title: "asset-remove-confirmation-title".localized,
                detail: String(format: "asset-remove-warning".localized, "\(assetDetail.unitName ?? "")", "\(account.name ?? "")"),
                actionTitle: "asset-transfer-balance".localized
            )
        }
        
        let controller = open(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: .crossDissolve,
                transitioningDelegate: nil
                )
        ) as? AssetActionConfirmationViewController
        
        controller?.delegate = self
    }
}

extension AssetRemovalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return layout.current.cellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.cellHeight
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: layout.current.headerHeight)
    }
}

extension AssetRemovalViewController: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    ) {
        guard let index = assetDetail.index,
            let indexIntValue = Int64(index) else {
                return
        }
        
        let assetTransactionDraft = AssetTransactionDraft(
            fromAccount: account,
            recipient: assetDetail.creator,
            amount: 0,
            assetIndex: indexIntValue,
            assetCreator: assetDetail.creator
        )
        transactionManager?.setAssetTransactionDraft(assetTransactionDraft)
        transactionManager?.composeAssetTransactionData(for: account, isClosingTransaction: true)
    }
}

extension AssetRemovalViewController: TransactionManagerDelegate {
    func transactionManagerDidComposedAssetTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: AssetTransactionDraft?
    ) {
        guard let removedAssetDetail = getRemovedAssetDetail(from: draft) else {
            return
        }
        
        delete(removedAssetDetail)
        delegate?.assetRemovalViewController(self, didRemove: removedAssetDetail, from: account)
        dismissScreen()
    }
    
    private func getRemovedAssetDetail(from draft: AssetTransactionDraft?) -> AssetDetail? {
        guard let removedAssetDetail = account.assetDetails.first(where: { assetDetail -> Bool in
            guard let index = assetDetail.index,
                let assetIndex = draft?.assetIndex else {
                    return false
            }
            return index == "\(assetIndex)"
        }) else {
            return nil
        }
        
        return removedAssetDetail
    }
    
    private func delete(_ removedAssetDetail: AssetDetail) {
        account.assetDetails = account.assetDetails.filter { assetDetail -> Bool in
            guard let assetIndex = assetDetail.index,
                let removedAssetIndex = removedAssetDetail.index else {
                    return true
            }
            
            return assetIndex != removedAssetIndex
        }
    }
}

extension AssetRemovalViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultSectionInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        let cellSpacing: CGFloat = 5.0
        let cellHeight: CGFloat = 50.0
        let headerHeight: CGFloat = 49.0
    }
}
