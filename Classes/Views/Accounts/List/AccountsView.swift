//
//  AssetListView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountsView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountsViewDelegate?
    
    private lazy var accountsHeaderView: MainHeaderView = {
        let view = MainHeaderView()
        view.setTitle("accounts-title".localized)
        return view
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    private(set) lazy var accountsCollectionView: AssetsCollectionView = {
        let collectionView = AssetsCollectionView(containsPendingAssets: true)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SharedColors.primaryBackground
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 20.0, right: 20.0)
        
        collectionView.register(AlgoAssetCell.self, forCellWithReuseIdentifier: AlgoAssetCell.reusableIdentifier)
        collectionView.register(
            AccountHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier
        )
        collectionView.register(
            AccountFooterSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: AccountFooterSupplementaryView.reusableIdentifier
        )
        
        return collectionView
    }()
    
    override func setListeners() {
        accountsHeaderView.delegate = self
    }
    
    override func prepareLayout() {
        setupAccountsHeaderViewLayout()
        setupAccountsCollectionViewLayout()
    }
}

extension AccountsView {
    private func setupAccountsHeaderViewLayout() {
        addSubview(accountsHeaderView)
        
        accountsHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    private func setupAccountsCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(accountsHeaderView.snp.bottom).offset(layout.current.listTopInset)
        }
        
        accountsCollectionView.backgroundView = contentStateView
    }
}

extension AccountsView {
    func setHeaderButtonsHidden(_ hidden: Bool) {
        accountsHeaderView.setQRButtonHidden(hidden)
        accountsHeaderView.setAddButtonHidden(hidden)
    }
    
    func setTestNetLabelHidden(_ hidden: Bool) {
        accountsHeaderView.setTestNetLabelHidden(hidden)
    }
}

extension AccountsView: MainHeaderViewDelegate {
    func mainHeaderViewDidTapQRButton(_ mainHeaderView: MainHeaderView) {
        delegate?.accountsViewDidTapQRButton(self)
    }
    
    func mainHeaderViewDidTapAddButton(_ mainHeaderView: MainHeaderView) {
        delegate?.accountsViewDidTapAddButton(self)
    }
}

extension AccountsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let listTopInset: CGFloat = 12.0
    }
}

protocol AccountsViewDelegate: class {
    func accountsViewDidTapQRButton(_ accountsView: AccountsView)
    func accountsViewDidTapAddButton(_ accountsView: AccountsView)
}
