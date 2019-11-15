//
//  AccountsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetDetailViewDelegate: class {
    func assetDetailViewDidTapSendButton(_ assetDetailView: AssetDetailView)
    func assetDetailViewDidTapReceiveButton(_ assetDetailView: AssetDetailView)
    func assetDetailView(_ assetDetailView: AssetDetailView, didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer)
    func assetDetailViewDidTapRewardView(_ assetDetailView: AssetDetailView)
}

class AssetDetailView: BaseView {

    struct LayoutConstants: AdaptiveLayoutConstants {
        static let headerHeight: CGFloat = 255.0
        static let smallHeaderHeight: CGFloat = 111.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var accountsHeaderContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private(set) lazy var headerView: AssetDetailHeaderView = {
        let view = AssetDetailHeaderView()
        return view
    }()
    
    private(set) lazy var smallHeaderView: AssetDetailSmallHeaderView = {
        let view = AssetDetailSmallHeaderView()
        view.alpha = 0.0
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
        collectionView.contentInset.top = 255.0
        
        collectionView.register(TransactionHistoryCell.self, forCellWithReuseIdentifier: TransactionHistoryCell.reusableIdentifier)
        collectionView.register(PendingTransactionCell.self, forCellWithReuseIdentifier: PendingTransactionCell.reusableIdentifier)
        collectionView.register(RewardCell.self, forCellWithReuseIdentifier: RewardCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    weak var delegate: AssetDetailViewDelegate?
    
    // MARK: Setup
    
    override func linkInteractors() {
        headerView.delegate = self
        smallHeaderView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTransactionHistoryCollectionViewLayout()
        setupAccountsHeaderContainerViewLayout()
        setupHeaderViewLayout()
        setupSmallHeaderViewLayout()
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
    
    private func setupHeaderViewLayout() {
        accountsHeaderContainerView.addSubview(headerView)
        
        headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupSmallHeaderViewLayout() {
        accountsHeaderContainerView.addSubview(smallHeaderView)
        
        smallHeaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContentStateView() {
        transactionHistoryCollectionView.backgroundView = contentStateView
        
        contentStateView.loadingIndicator.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(326.0 * verticalScale)
        }
    }
}

// MARK: AssetDetailHeaderViewDelegate

extension AssetDetailView: AssetDetailHeaderViewDelegate {
    func assetDetailHeaderViewDidTapSendButton(_ assetDetailHeaderView: AssetDetailHeaderView) {
        delegate?.assetDetailViewDidTapSendButton(self)
    }
    
    func assetDetailHeaderViewDidTapReceiveButton(_ assetDetailHeaderView: AssetDetailHeaderView) {
        delegate?.assetDetailViewDidTapReceiveButton(self)
    }
    
    func assetDetailHeaderView(
        _ assetDetailHeaderView: AssetDetailHeaderView,
        didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer
    ) {
        delegate?.assetDetailView(self, didTrigger: dollarValueGestureRecognizer)
    }
    
    func assetDetailHeaderViewDidTapRewardView(_ assetDetailHeaderView: AssetDetailHeaderView) {
        delegate?.assetDetailViewDidTapRewardView(self)
    }
}

// MARK: AssetDetailSmallHeaderViewDelegate

extension AssetDetailView: AssetDetailSmallHeaderViewDelegate {
    func assetDetailSmallHeaderViewDidTapSendButton(_ assetDetailHeaderView: AssetDetailSmallHeaderView) {
        delegate?.assetDetailViewDidTapSendButton(self)
    }
    
    func assetDetailSmallHeaderViewDidTapReceiveButton(_ assetDetailHeaderView: AssetDetailSmallHeaderView) {
        delegate?.assetDetailViewDidTapReceiveButton(self)
    }
}
