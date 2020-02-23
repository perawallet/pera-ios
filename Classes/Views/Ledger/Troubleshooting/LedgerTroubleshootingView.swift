//
//  LedgerTroubleshootingView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTroubleshootingView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var optionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = layout.current.contentInset
        collectionView.register(
            LedgerTroubleshootingOptionCell.self,
            forCellWithReuseIdentifier: LedgerTroubleshootingOptionCell.reusableIdentifier
        )
        return collectionView
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupOptionsCollectionViewLayout()
    }
}

extension LedgerTroubleshootingView {
    private func setupOptionsCollectionViewLayout() {
        addSubview(optionsCollectionView)
        
        optionsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerTroubleshootingView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let contentInset = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
}
