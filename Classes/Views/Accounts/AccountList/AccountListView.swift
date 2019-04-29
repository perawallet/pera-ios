//
//  AccountListView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountListViewDelegate: class {
    
    func accountListViewDidTapAddButton(_ accountListView: AccountListView)
    func accountListView(_ accountListView: AccountListView, didSelect account: Account)
}

class AccountListView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewTopInset: CGFloat = 10.0
        let accountListTopInset: CGFloat = 20.0
        let accountListBottomInset: CGFloat = -20.0
        let buttonBottomInset: CGFloat = 6.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components

    private lazy var topImageView = UIImageView(image: img("icon-modal-top"))
    
    private(set) lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        
        collectionView.register(AccountViewCell.self, forCellWithReuseIdentifier: AccountViewCell.reusableIdentifier)
        collectionView.register(AccountsTotalDisplayCell.self, forCellWithReuseIdentifier: AccountsTotalDisplayCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var addButton = MainButton(title: "account-list-add".localized)
    
    weak var delegate: AccountListViewDelegate?
    
    private var accountListLayoutBuilder: AccountListLayoutBuilder
    private var accountListDataSource: AccountListDataSource
    
    private let mode: AccountListMode
    
    init(mode: AccountListMode) {
        self.mode = mode
        
        accountListLayoutBuilder = AccountListLayoutBuilder()
        accountListDataSource = AccountListDataSource(mode: mode)
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        addButton.addTarget(self, action: #selector(notifyDelegateToAddButtonTapped), for: .touchUpInside)
    }
    
    override func linkInteractors() {
        accountListLayoutBuilder.delegate = self
        accountsCollectionView.dataSource = accountListDataSource
        accountsCollectionView.delegate = accountListLayoutBuilder
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTopImageViewLayout()
        
        if mode == .addable {
            setupAddButtonLayout()
        }
        
        setupAccountCollectionViewLayout()
    }

    private func setupTopImageViewLayout() {
        addSubview(topImageView)
        
        topImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageViewTopInset)
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().inset(layout.current.buttonBottomInset + safeAreaBottom)
        }
    }
    
    private func setupAccountCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom).offset(layout.current.accountListTopInset)
            
            if mode == .addable {
                make.bottom.equalTo(addButton.snp.top).offset(layout.current.accountListBottomInset)
            } else {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(layout.current.buttonBottomInset)
            }
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToAddButtonTapped() {
        delegate?.accountListViewDidTapAddButton(self)
    }
}

// MARK: - AccountListLayoutBuilderDelegate
extension AccountListView: AccountListLayoutBuilderDelegate {
    func accountListLayoutBuilder(_ layoutBuilder: AccountListLayoutBuilder, didSelectAt indexPath: IndexPath) {
        let accounts = accountListDataSource.accounts
        
        guard indexPath.item < accounts.count else {
            return
        }
        
        let account = accounts[indexPath.item]
        
        delegate?.accountListView(self, didSelect: account)
    }
}
