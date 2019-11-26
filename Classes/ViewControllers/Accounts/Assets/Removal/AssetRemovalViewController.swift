//
//  AssetRemovalViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetRemovalViewControllerDelegate: class {
    func assetRemovalViewController(_ assetRemovalViewController: AssetRemovalViewController, didRemove asset: AssetDetail)
}

class AssetRemovalViewController: BaseViewController {
    
    private lazy var assetRemovalView = AssetRemovalView()
    
    private var account: Account
    private var accountsLayoutBuilder: AccountsLayoutBuilder
    
    private let viewModel = AssetRemovalViewModel()
    
    weak var delegate: AssetRemovalViewControllerDelegate?
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        accountsLayoutBuilder = AccountsLayoutBuilder()
        super.init(configuration: configuration)
    }
    
    override func setListeners() {
        assetRemovalView.assetsCollectionView.delegate = accountsLayoutBuilder
        assetRemovalView.assetsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        setupAssetRemovalViewLayout()
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
        guard let assets = account.assets else {
            return 1
        }
        
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AssetActionableCell.reusableIdentifier,
            for: indexPath) as? AssetActionableCell else {
                fatalError("Index path is out of bounds")
        }
        
        guard let assetDetails = account.assetDetails else {
            return cell
        }
        
        cell.delegate = self
        
        let assetDetail = assetDetails[indexPath.item]
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
        guard let assetDetails = account.assetDetails,
            let index = assetRemovalView.assetsCollectionView.indexPath(for: assetActionableCell) else {
            return
        }
        
        let assetDetail = assetDetails[index.item]
        let assetAlertDraft = AssetAlertDraft(account: account, assetDetail: assetDetail)
        
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

extension AssetRemovalViewController: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    ) {
        delegate?.assetRemovalViewController(self, didRemove: assetDetail)
    }
}
