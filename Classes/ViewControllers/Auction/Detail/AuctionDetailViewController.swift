//
//  AuctionDetailViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Charts

class AuctionDetailViewController: BaseScrollViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0 * verticalScale
        let headerViewHeight: CGFloat = 245.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var auctionDetailView: AuctionDetailView = {
        let view = AuctionDetailView()
        return view
    }()
    
    private lazy var placeBidViewController = PlaceBidViewController(configuration: configuration)
    
    private lazy var myBidsViewController = MyBidsViewController(configuration: configuration)
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "auction-detail-title".localized
    }
    
    override func linkInteractors() {
        auctionDetailView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupAuctionDetailHeaderViewLayout()
        
        addPlaceBidViewController()
    }
    
    private func setupAuctionDetailHeaderViewLayout() {
        contentView.addSubview(auctionDetailView)
        
        auctionDetailView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.height.equalTo(layout.current.headerViewHeight)
        }
    }
    
    private func addPlaceBidViewController() {
        addChild(placeBidViewController)
        
        contentView.addSubview(placeBidViewController.view)
        
        placeBidViewController.view.snp.makeConstraints { make in
            make.top.equalTo(auctionDetailView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        placeBidViewController.didMove(toParent: self)
    }
    
    private func addMyBidsViewController() {
        addChild(myBidsViewController)
        
        contentView.addSubview(myBidsViewController.view)
        
        myBidsViewController.view.snp.makeConstraints { make in
            make.top.equalTo(auctionDetailView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        myBidsViewController.didMove(toParent: self)
    }
}

// MARK: AuctionDetailViewDelegate

extension AuctionDetailViewController: AuctionDetailViewDelegate {
    
    func auctionDetailViewDidTapPlaceBidButton(_ auctionDetailView: AuctionDetailView) {
        myBidsViewController.removeFromParentController()
        
        addPlaceBidViewController()
    }
    
    func auctionDetailViewDidTapMyBidsButton(_ auctionDetailView: AuctionDetailView) {
        placeBidViewController.removeFromParentController()
        
        addMyBidsViewController()
    }
}
