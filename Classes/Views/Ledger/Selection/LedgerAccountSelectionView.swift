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
        flowLayout.minimumLineSpacing = 20.0
        flowLayout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SharedColors.secondaryBackground
        collectionView.contentInset = .zero
        collectionView.layer.cornerRadius = 12.0
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
        setupAddButtonLayout()
        setupAccountsCollectionViewLayout()
    }
}

extension LedgerAccountSelectionView {
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.ledgerAccountSelectionViewDidAddAccount(self)
    }
}

extension LedgerAccountSelectionView {
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
    
    private func setupAccountsCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addButton.snp.top).offset(layout.current.listBottomInset)
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
