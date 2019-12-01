//
//  AssetListViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetListViewControllerDelegate: class {
    func assetListViewController(_ viewController: AssetListViewController, didSelectAlgo account: Account)
    func assetListViewController(_ viewController: AssetListViewController, didSelectAsset assetDetail: AssetDetail)
}

class AssetListViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var assetListView = AssetListView()
    
    private let viewModel = AssetListViewModel()
    
    private var account: Account

    weak var delegate: AssetListViewControllerDelegate?
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = .white
    }
    
    override func setListeners() {
        assetListView.assetsCollectionView.dataSource = self
        assetListView.assetsCollectionView.delegate = self
    }
    
    override func prepareLayout() {
        setupAssetListViewLayout()
    }
}

extension AssetListViewController {
    private func setupAssetListViewLayout() {
        view.addSubview(assetListView)
        
        assetListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return account.assetDetails.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AssetSelectionCell.reusableIdentifier,
            for: indexPath) as? AssetSelectionCell else {
                fatalError("Index path is out of bounds")
        }
        
        viewModel.configure(cell, at: indexPath, with: account)
        return cell
    }
}

extension AssetListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: view.frame.width, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            delegate?.assetListViewController(self, didSelectAlgo: account)
            return
        }
        
        let assetDetail = account.assetDetails[indexPath.item - 1]
        delegate?.assetListViewController(self, didSelectAsset: assetDetail)
    }
}
