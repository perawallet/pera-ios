//
//  SelectAssetView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SelectAssetView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var contentStateView = ContentStateView()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.primaryBackground
        return view
    }()
    
    private(set) lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SharedColors.secondaryBackground
        collectionView.contentInset = .zero
        
        collectionView.register(AlgoAssetCell.self, forCellWithReuseIdentifier: AlgoAssetCell.reusableIdentifier)
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: AssetCell.reusableIdentifier)
        collectionView.register(
            SelectAssetHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SelectAssetHeaderSupplementaryView.reusableIdentifier
        )
        
        return collectionView
    }()

    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupAccountsCollectionViewLayout()
    }
}

extension SelectAssetView {
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { maker in
            maker.leading.top.trailing.equalToSuperview()
            maker.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupAccountsCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        accountsCollectionView.backgroundView = contentStateView
    }
}

extension SelectAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
    }
}
