//
//  MyBidsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MyBidsViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 30.0, height: 122.0)
        let cellSpacing: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) var bids = [Bid]()
    
    // MARK: Components
    
    private(set) lazy var myBidsView: MyBidsView = {
        let view = MyBidsView()
        return view
    }()
    
    // MARK: Setup
    
    override func linkInteractors() {
        myBidsView.myBidsCollectionView.delegate = self
        myBidsView.myBidsCollectionView.dataSource = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupMyBidsViewLayout()
    }
    
    private func setupMyBidsViewLayout() {
        view.addSubview(myBidsView)
        
        myBidsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let collectionViewHeight = CGFloat(10) * layout.current.cellSize.height + CGFloat(10) * layout.current.cellSpacing
        
        myBidsView.myBidsCollectionView.snp.updateConstraints { make in
            make.height.equalTo(collectionViewHeight)
        }
        
        myBidsView.myBidsCollectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource

extension MyBidsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BidCell.reusableIdentifier,
            for: indexPath) as? BidCell else {
                fatalError("Index path is out of bounds")
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension MyBidsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return layout.current.cellSize
    }
}
