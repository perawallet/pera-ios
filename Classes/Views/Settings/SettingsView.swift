//
//  SettingsView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsView: BaseView {
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = SharedColors.secondaryBackground
        collectionView.contentInset = UIEdgeInsets(top: 12.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.register(SettingsDetailCell.self, forCellWithReuseIdentifier: SettingsDetailCell.reusableIdentifier)
        collectionView.register(SettingsInfoCell.self, forCellWithReuseIdentifier: SettingsInfoCell.reusableIdentifier)
        collectionView.register(SettingsToggleCell.self, forCellWithReuseIdentifier: SettingsToggleCell.reusableIdentifier)
        collectionView.register(
            SettingsFooterSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: SettingsFooterSupplementaryView.reusableIdentifier
        )
        return collectionView
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }

    override func prepareLayout() {
        setupCollectionViewLayout()
    }
}

extension SettingsView {
    private func setupCollectionViewLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}
