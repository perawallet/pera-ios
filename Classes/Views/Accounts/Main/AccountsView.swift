//
//  AccountsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountsViewDelegate: class {
    
    func accountsViewDidTapSendButton(_ accountsView: AccountsView)
    func accountsViewDidTapReceiveButton(_ accountsView: AccountsView)
}

class AccountsView: BaseView {

    struct LayoutConstants: AdaptiveLayoutConstants {
        static let headerHeight: CGFloat = 276.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var accountsHeaderView: AccountsHeaderView = {
        let view = AccountsHeaderView()
        return view
    }()
    
    private(set) lazy var transactionHistoryCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        
        collectionView.register(TransactionHistoryCell.self, forCellWithReuseIdentifier: TransactionHistoryCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    weak var delegate: AccountsViewDelegate?
    
    // MARK: Setup
    
    override func linkInteractors() {
        accountsHeaderView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAccountsHeaderViewLayout()
        setupTransactionHistoryCollectionViewLayout()
        setupContentStateView()
    }
    
    private func setupAccountsHeaderViewLayout() {
        addSubview(accountsHeaderView)
        
        accountsHeaderView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(LayoutConstants.headerHeight)
        }
    }
    
    private func setupTransactionHistoryCollectionViewLayout() {
        addSubview(transactionHistoryCollectionView)
        
        transactionHistoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(accountsHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupContentStateView() {
        transactionHistoryCollectionView.backgroundView = contentStateView
    }
}

// MARK: AccountsHeaderViewDelegate

extension AccountsView: AccountsHeaderViewDelegate {
    
    func accountsHeaderViewDidTapSendButton(_ accountsHeaderView: AccountsHeaderView) {
        delegate?.accountsViewDidTapSendButton(self)
    }
    
    func accountsHeaderViewDidTapReceiveButton(_ accountsHeaderView: AccountsHeaderView) {
        delegate?.accountsViewDidTapReceiveButton(self)
    }
}
