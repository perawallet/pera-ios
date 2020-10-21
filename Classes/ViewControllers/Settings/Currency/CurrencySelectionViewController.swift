//
//  CurrencySelectionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class CurrencySelectionViewController: BaseViewController {
    
    private lazy var currencySelectionView = SingleSelectionListView()
    
    private lazy var dataSource: CurrencySelectionDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return CurrencySelectionDataSource(api: api)
    }()
    
    weak var delegate: CurrencySelectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrencies()
    }
    
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
    func currencySelectionDataSourceDidFetchCurrencies(_ currencySelectionDataSource: CurrencySelectionDataSource) {
        currencySelectionView.endRefreshing()
        currencySelectionView.setNormalState()
        currencySelectionView.reloadData()
    }
    
    func currencySelectionDataSourceDidFailToFetch(_ currencySelectionDataSource: CurrencySelectionDataSource) {
        currencySelectionView.endRefreshing()
        currencySelectionView.setErrorState()
        currencySelectionView.reloadData()
    }
    
    private func getCurrencies() {
        currencySelectionView.setLoadingState()
        dataSource.loadData()
    }
}

extension CurrencySelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCurrency = dataSource.currency(at: indexPath.item) else {
            return
        }
        
        CurrencyChangeEvent(currencyId: selectedCurrency.id).logEvent()
        
        api?.session.preferredCurrency = selectedCurrency.id
        currencySelectionView.reloadData()
        delegate?.currencySelectionViewControllerDidSelectCurrency(self)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60.0)
    }
}

extension CurrencySelectionViewController: SingleSelectionListViewDelegate {
    func singleSelectionListViewDidRefreshList(_ singleSelectionListView: SingleSelectionListView) {
        getCurrencies()
    }
    
    func singleSelectionListViewDidTryAgain(_ singleSelectionListView: SingleSelectionListView) {
        getCurrencies()
    }
}

protocol CurrencySelectionViewControllerDelegate: class {
    func currencySelectionViewControllerDidSelectCurrency(_ currencySelectionViewController: CurrencySelectionViewController)
}
