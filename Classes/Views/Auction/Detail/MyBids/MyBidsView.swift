//
//  MyBidsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

class MyBidsView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 15.0
        let potentialAlgosViewTopInset: CGFloat = 10.0
        let potentialAlgosViewHeight: CGFloat = 50.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var myBidsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        
        collectionView.register(BidCell.self, forCellWithReuseIdentifier: BidCell.reusableIdentifier)
        collectionView.register(LimitOrderCell.self, forCellWithReuseIdentifier: LimitOrderCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private(set) lazy var totalPotentialAlgosDisplayView: PotentialAlgosDisplayView = {
        let view = PotentialAlgosDisplayView(mode: .total)
        return view
    }()
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupMyBidsCollectionViewLayout()
        setupTotalPotentialAlgosDisplayViewLayout()
    }
    
    private func setupMyBidsCollectionViewLayout() {
        addSubview(myBidsCollectionView)
        
        myBidsCollectionView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.height.equalTo(0.0)
        }
    }
    
    private func setupTotalPotentialAlgosDisplayViewLayout() {
        addSubview(totalPotentialAlgosDisplayView)
        
        totalPotentialAlgosDisplayView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(myBidsCollectionView.snp.bottom).offset(layout.current.potentialAlgosViewTopInset)
            make.height.equalTo(layout.current.potentialAlgosViewHeight)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset + safeAreaBottom)
        }
    }
}
