//
//  CurrencySelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class CurrencySelectionView: BaseView {
    
    weak var delegate: CurrencySelectionViewDelegate?
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SharedColors.secondaryBackground
        collectionView.contentInset = .zero
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(SingleSelectionCell.self, forCellWithReuseIdentifier: SingleSelectionCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var errorView = ListErrorView()
    
    private lazy var contentStateView = ContentStateView()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        errorView.setImage(img("icon-warning-error"))
        errorView.setTitle("transaction-filter-error-title".localized)
        errorView.setSubtitle("transaction-filter-error-subtitle".localized)
    }
    
    override func linkInteractors() {
        errorView.delegate = self
    }

    override func prepareLayout() {
        setupCollectionViewLayout()
    }
}

extension CurrencySelectionView {
    private func setupCollectionViewLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundView = contentStateView
        collectionView.refreshControl = refreshControl
    }
}

extension CurrencySelectionView {
    @objc
    private func didRefreshList() {
        delegate?.currencySelectionViewDidRefreshList(self)
    }
}

extension CurrencySelectionView {
    func reloadData() {
        collectionView.reloadData()
    }
    
    func setListDelegate(_ delegate: UICollectionViewDelegate?) {
        collectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        collectionView.dataSource = dataSource
    }
    
    var isListRefreshing: Bool {
        return refreshControl.isRefreshing
    }
    
    func endRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func setErrorState() {
        collectionView.contentState = .error(errorView)
    }
    
    func setNormalState() {
        collectionView.contentState = .none
    }

    func setLoadingState() {
        if !refreshControl.isRefreshing {
            collectionView.contentState = .loading
        }
    }
}

extension CurrencySelectionView: ListErrorViewDelegate {
    func listErrorViewDidTryAgain(_ listErrorView: ListErrorView) {
        delegate?.currencySelectionViewDidTryAgain(self)
    }
}

protocol CurrencySelectionViewDelegate: class {
    func currencySelectionViewDidRefreshList(_ currencySelectionView: CurrencySelectionView)
    func currencySelectionViewDidTryAgain(_ currencySelectionView: CurrencySelectionView)
}
