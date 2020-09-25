//
//  CurrencySelectionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class CurrencySelectionViewController: BaseViewController {
    
    private lazy var currencySelectionView = CurrencySelectionView()
    
    private lazy var dataSource: CurrencySelectionDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return CurrencySelectionDataSource(api: api)
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "settings-currency".localized
    }
    
    override func linkInteractors() {
        currencySelectionView.delegate = self
        currencySelectionView.setDataSource(dataSource)
        currencySelectionView.setListDelegate(self)
        dataSource.delegate = self
    }
    
    override func prepareLayout() {
        setupCurrencySelectionViewLayout()
    }
}

extension CurrencySelectionViewController {
    private func setupCurrencySelectionViewLayout() {
        view.addSubview(currencySelectionView)
        
        currencySelectionView.snp.makeConstraints { make in
            make.top.safeEqualToTop(of: self)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension CurrencySelectionViewController: CurrencySelectionDataSourceDelegate {
    func currencySelectionDataSourceDidFetchNotifications(_ currencySelectionDataSource: CurrencySelectionDataSource) {
        currencySelectionView.endRefreshing()
        currencySelectionView.setNormalState()
        currencySelectionView.reloadData()
    }
    
    func currencySelectionDataSourceDidFailToFetch(_ currencySelectionDataSource: CurrencySelectionDataSource) {
        currencySelectionView.endRefreshing()
        currencySelectionView.setErrorState()
        currencySelectionView.reloadData()
    }
}

extension CurrencySelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60.0)
    }
}

extension CurrencySelectionViewController: CurrencySelectionViewDelegate {
    func currencySelectionViewDidRefreshList(_ currencySelectionView: CurrencySelectionView) {
        
    }
    
    func currencySelectionViewDidTryAgain(_ currencySelectionView: CurrencySelectionView) {
        
    }
}
