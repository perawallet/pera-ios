//
//  SettingsView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsView: BaseView {
    
    // MARK: Components
    
    private(set) lazy var contactsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.register(ContactCell.self, forCellWithReuseIdentifier: ContactCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupCollectionViewLayout()
    }
    
    
    private func setupCollectionViewLayout() {
        addSubview(contactsCollectionView)
        
        contactsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        contactsCollectionView.backgroundView = contentStateView
    }
}

