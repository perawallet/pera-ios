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
    var auctionStatus: ActiveAuction
    
    // MARK: Components
    
    private(set) lazy var myBidsView: MyBidsView = {
        let view = MyBidsView()
        return view
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "auction-detail-bids-empty-title".localized,
        topImage: img("img-bids-empty"),
        bottomImage: nil
    )
    
    // MARK: Initialization
    
    init(auction: Auction, user: AuctionUser, auctionStatus: ActiveAuction, configuration: ViewControllerConfiguration) {
        self.auction = auction
        self.user = user
        self.auctionStatus = auctionStatus
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        emptyStateView.backgroundColor = .clear
        
        viewModel.configure(myBidsView, with: bids, for: emptyStateView)
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
        
        if bids.isEmpty && !auctionStatus.isBiddable() {
            myBidsView.myBidsCollectionView.contentState = .empty(self.emptyStateView)
        } else {
            myBidsView.myBidsCollectionView.contentState = .loading
        }
    }
    
    func fetchMyBids(then handler: @escaping EmptyHandler) {
        guard let username = user.username else {
            return
        }
        
        api?.fetchBids(in: "\(auction.id)", for: username) { response in
            switch response {
            case let .success(myBids):
                self.bids = myBids
                
                self.viewModel.configure(self.myBidsView, with: myBids, for: self.emptyStateView)
                self.updateCollectionViewLayoutForBids()
                
                self.myBidsView.myBidsCollectionView.reloadData()
            case .failure:
                self.myBidsView.myBidsCollectionView.contentState = .empty(self.emptyStateView)
                self.myBidsView.myBidsCollectionView.backgroundColor = .clear
            }
            
            handler()
        }
    }
    
    func updateCollectionViewLayoutForBids() {
        var collectionViewHeight: CGFloat
        
        if bids.isEmpty {
            collectionViewHeight = layout.current.emptyCollectionViewHeight
            
            emptyStateView.titleLabel.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(layout.current.cellSpacing)
            }
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
        guard indexPath.item < bids.count else {
            fatalError("Index path is out of bounds")
        }
        
        let bid = bids[indexPath.row]
        
        if bid.status == .queued {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LimitOrderCell.reusableIdentifier,
                for: indexPath) as? LimitOrderCell else {
                    fatalError("Index path is out of bounds")
            }
            
            cell.delegate = self
            
            viewModel.configure(cell, with: bid)
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BidCell.reusableIdentifier,
                for: indexPath) as? BidCell else {
                    fatalError("Index path is out of bounds")
            }
            
            viewModel.configure(cell, with: bid)
            
            return cell
        }
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

// MARK: LimitOrderCellDelegate

extension MyBidsViewController: LimitOrderCellDelegate {
    
    func limitOrderCellDidTapRetractButton(_ limitOrderCell: LimitOrderCell) {
        guard let indexPath = myBidsView.myBidsCollectionView.indexPath(for: limitOrderCell) else {
            return
        }
        
        let bid = bids[indexPath.row]
        
        api?.retractBid(with: "\(bid.id)", from: "\(auction.id)") { response in
            switch response {
            case .success:
                self.myBidsView.myBidsCollectionView.reloadData()
            case .failure:
                self.displaySimpleAlertWith(title: "title-error".localized, message: "auction-detail-retract-error".localized)
            }
        }
    }
}
