//
//  AccountsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetDetailView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var headerView = AssetDetailHeaderView()
    
    private(set) lazy var transactionHistoryCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(TransactionHistoryCell.self, forCellWithReuseIdentifier: TransactionHistoryCell.reusableIdentifier)
        collectionView.register(PendingTransactionCell.self, forCellWithReuseIdentifier: PendingTransactionCell.reusableIdentifier)
        collectionView.register(RewardCell.self, forCellWithReuseIdentifier: RewardCell.reusableIdentifier)
        collectionView.register(
            TransactionHistoryHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TransactionHistoryHeaderSupplementaryView.reusableIdentifier
        )
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    weak var delegate: AssetDetailViewDelegate?
    
    override func linkInteractors() {
        headerView.delegate = self
    }
    
    override func prepareLayout() {
        setupHeaderViewLayout()
        setupTransactionHistoryCollectionViewLayout()
        setupContentStateView()
    }
}

extension AssetDetailView {
    private func setupHeaderViewLayout() {
        addSubview(headerView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupTransactionHistoryCollectionViewLayout() {
        addSubview(transactionHistoryCollectionView)
        
        transactionHistoryCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(layout.current.listTopInset)
        }
    }
    
    private func setupContentStateView() {
        transactionHistoryCollectionView.backgroundView = contentStateView
        
        contentStateView.loadingIndicator.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(326.0 * verticalScale)
        }
    }
}

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
    
    func assetDetailHeaderView(
        _ assetDetailHeaderView: AssetDetailHeaderView,
        didTriggerAssetIdCopyValue gestureRecognizer: UILongPressGestureRecognizer
    ) {
        delegate?.assetDetailView(self, didTriggerAssetIdCopyValue: gestureRecognizer)
    }
    
    func assetDetailHeaderViewDidTapRewardView(_ assetDetailHeaderView: AssetDetailHeaderView) {
        delegate?.assetDetailViewDidTapRewardView(self)
    }
}

extension AssetDetailView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let horizontalInset: CGFloat = 20.0
        let listTopInset: CGFloat = 32.0
        static var algosHeaderHeight: CGFloat = 264.0
        static var assetHeaderHeight: CGFloat = 216.0
    }
}

protocol AssetDetailViewDelegate: class {
    func assetDetailViewDidTapSendButton(_ assetDetailView: AssetDetailView)
    func assetDetailViewDidTapReceiveButton(_ assetDetailView: AssetDetailView)
    func assetDetailView(_ assetDetailView: AssetDetailView, didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer)
    func assetDetailView(_ assetDetailView: AssetDetailView, didTriggerAssetIdCopyValue gestureRecognizer: UILongPressGestureRecognizer)
    func assetDetailViewDidTapRewardView(_ assetDetailView: AssetDetailView)
}
