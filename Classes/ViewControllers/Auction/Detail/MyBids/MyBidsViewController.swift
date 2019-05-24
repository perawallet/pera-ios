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
        let emptyCollectionViewHeight: CGFloat = 155.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private let viewModel = MyBidsViewModel()
    
    private(set) var bids = [Bid]()
    
    var auction: Auction
    var user: AuctionUser
    var activeAuction: ActiveAuction
    
    // MARK: Components
    
    private(set) lazy var myBidsView: MyBidsView = {
        let view = MyBidsView()
        return view
    }()
    
    // MARK: Initialization
    
    init(auction: Auction, user: AuctionUser, activeAuction: ActiveAuction, configuration: ViewControllerConfiguration) {
        self.auction = auction
        self.user = user
        self.activeAuction = activeAuction
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        viewModel.configure(myBidsView, with: bids)
    }
    
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
        
        myBidsView.myBidsCollectionView.reloadData()
    }
    
    func fetchMyBids() {
        guard let username = user.username else {
            return
        }
        
        api?.fetchBids(in: "\(auction.id)", for: username) { response in
            switch response {
            case let .success(myBids):
                self.bids = myBids
                
                self.viewModel.configure(self.myBidsView, with: myBids)
                self.updateCollectionViewLayoutForBids()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func updateCollectionViewLayoutForBids() {
        var collectionViewHeight: CGFloat
        
        if bids.isEmpty {
            collectionViewHeight = layout.current.emptyCollectionViewHeight
        } else {
            collectionViewHeight = CGFloat(bids.count) * layout.current.cellSize.height + CGFloat(bids.count) * layout.current.cellSpacing
        }
        
        myBidsView.myBidsCollectionView.snp.updateConstraints { make in
            make.height.equalTo(collectionViewHeight)
        }
    }
}

// MARK: UICollectionViewDataSource

extension MyBidsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BidCell.reusableIdentifier,
            for: indexPath) as? BidCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.item < bids.count {
            let bid = bids[indexPath.row]
            viewModel.configure(cell, with: bid)
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
