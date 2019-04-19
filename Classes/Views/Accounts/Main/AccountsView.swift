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
        static let smallHeaderHeight: CGFloat = 134.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var accountsHeaderContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private(set) lazy var accountsHeaderView: AccountsHeaderView = {
        let view = AccountsHeaderView()
        return view
    }()
    
    private(set) lazy var accountsSmallHeaderView: AccountsSmallHeaderView = {
        let view = AccountsSmallHeaderView()
        view.alpha = 0.0
        return view
    }()
    
    private(set) lazy var transactionHistoryCollectionView: UICollectionView = {
        let flowLayout = AccountsFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset.top = 276.0
        
        collectionView.register(TransactionHistoryCell.self, forCellWithReuseIdentifier: TransactionHistoryCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    weak var delegate: AccountsViewDelegate?
    
    // MARK: Setup
    
    override func linkInteractors() {
        accountsHeaderView.delegate = self
        accountsSmallHeaderView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTransactionHistoryCollectionViewLayout()
        setupAccountsHeaderContainerViewLayout()
        setupAccountsHeaderViewLayout()
        setupAccountsSmallHeaderViewLayout()
        setupContentStateView()
    }
    
    private func setupTransactionHistoryCollectionViewLayout() {
        addSubview(transactionHistoryCollectionView)
        
        transactionHistoryCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupAccountsHeaderContainerViewLayout() {
        addSubview(accountsHeaderContainerView)
        
        accountsHeaderContainerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(LayoutConstants.headerHeight)
        }
    }
    
    private func setupAccountsHeaderViewLayout() {
        accountsHeaderContainerView.addSubview(accountsHeaderView)
        
        accountsHeaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupAccountsSmallHeaderViewLayout() {
        accountsHeaderContainerView.addSubview(accountsSmallHeaderView)
        
        accountsSmallHeaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContentStateView() {
        transactionHistoryCollectionView.backgroundView = contentStateView
        
        contentStateView.loadingIndicator.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(326.0)
        }
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

// MARK: AccountsSmallHeaderViewDelegate

extension AccountsView: AccountsSmallHeaderViewDelegate {
    
    func accountsSmallHeaderViewDidTapSendButton(_ accountsHeaderView: AccountsSmallHeaderView) {
        delegate?.accountsViewDidTapSendButton(self)
    }
    
    func accountsSmallHeaderViewDidTapReceiveButton(_ accountsHeaderView: AccountsSmallHeaderView) {
        delegate?.accountsViewDidTapReceiveButton(self)
    }
}
