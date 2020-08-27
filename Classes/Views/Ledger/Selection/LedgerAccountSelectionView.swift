//
//  LedgerAccountSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerAccountSelectionViewDelegate?
    
    private lazy var errorView = ListErrorView()
    
    private lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 24.0, left: 0.0, bottom: layout.current.bottomInset + safeAreaBottom + 60.0, right: 0.0)
        flowLayout.minimumLineSpacing = 20.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SharedColors.primaryBackground
        collectionView.contentInset = .zero
        collectionView.register(AccountSelectionCell.self, forCellWithReuseIdentifier: AccountSelectionCell.reusableIdentifier)
        collectionView.register(
            LedgerAccountSelectionHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: LedgerAccountSelectionHeaderSupplementaryView.reusableIdentifier
        )
        return collectionView
    }()
    
    private lazy var addButton = MainButton(title: "ledger-account-selection-add".localized)
    
    override func configureAppearance() {
        super.configureAppearance()
        errorView.setImage(img("icon-warning-error"))
        errorView.setTitle("transaction-filter-error-title".localized)
        errorView.setSubtitle("transaction-filter-error-subtitle".localized)
    }
    
    override func setListeners() {
        addButton.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAccountsCollectionViewLayout()
        setupAddButtonLayout()
    }
}

extension LedgerAccountSelectionView {
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.ledgerAccountSelectionViewDidAddAccount(self)
    }
}

extension LedgerAccountSelectionView {
    private func setupAccountsCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
}

extension LedgerAccountSelectionView {
    func reloadData() {
        accountsCollectionView.reloadData()
    }
    
    func setListDelegate(_ delegate: UICollectionViewDelegate?) {
        accountsCollectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        accountsCollectionView.dataSource = dataSource
    }
    
    func setErrorState() {
        accountsCollectionView.contentState = .error(errorView)
    }
    
    func setNormalState() {
        accountsCollectionView.contentState = .none
    }
    
    func setLoadingState() {
        accountsCollectionView.contentState = .loading
    }
    
    var selectedIndexes: [IndexPath] {
        return accountsCollectionView.indexPathsForSelectedItems ?? []
    }
}

extension LedgerAccountSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 16.0
        let listBottomInset: CGFloat = -4.0
    }
}

protocol LedgerAccountSelectionViewDelegate: class {
    func ledgerAccountSelectionViewDidAddAccount(_ ledgerAccountSelectionView: LedgerAccountSelectionView)
}
