//
//  AccountListView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountListView: BaseView {
    
    private let layout = Layout<LayoutConstants>()

    private lazy var topImageView = UIImageView(image: img("icon-modal-top"))
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 16.0)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
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
        return collectionView
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupTopImageViewLayout()
        setupTitleLabelLayout()
        setupAccountCollectionViewLayout()
    }
}

extension AccountListView {
    private func setupTopImageViewLayout() {
        addSubview(topImageView)
        
        topImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageViewTopInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom).offset(layout.current.titleLabelOffset)
        }
    }
    
    private func setupAccountCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.accountListTopInset)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(layout.current.accountListBottomInset)
        }
    }
}

extension AccountListView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewTopInset: CGFloat = 10.0
        let titleLabelOffset: CGFloat = 15.0
        let accountListTopInset: CGFloat = 20.0
        let accountListBottomInset: CGFloat = -20.0
    }
}
