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
        let headerViewHeight: CGFloat = 265.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var auctionDetailView: AuctionDetailView = {
        let view = AuctionDetailView()
        return view
    }()
    
    private var auction: Auction
    private var activeAuction: ActiveAuction
    
    private var chartValues = [ChartData]()
    
    private var pollingOperation: PollingOperation?
    
    private let viewModel = AuctionDetailViewModel()
    
    private lazy var placeBidViewController = PlaceBidViewController(
        auction: auction,
        activeAuction: activeAuction,
        configuration: configuration
    )
    
    private lazy var myBidsViewController = MyBidsViewController(
        auction: auction,
        activeAuction: activeAuction,
        configuration: configuration
    )
    
    // MARK: Initialization
    
    init(auction: Auction, activeAuction: ActiveAuction, configuration: ViewControllerConfiguration) {
        self.auction = auction
        self.activeAuction = activeAuction
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "auction-detail-title".localized
        
        viewModel.configure(auctionDetailView, with: auction, and: activeAuction)
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
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(layout.current.headerViewHeight)
        }
    }
    
    private func addPlaceBidViewController() {
        addChild(placeBidViewController)
        
        contentView.addSubview(placeBidViewController.view)
        
        placeBidViewController.view.snp.makeConstraints { make in
            make.top.equalTo(auctionDetailView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        placeBidViewController.didMove(toParent: self)
    }
    
    private func addMyBidsViewController() {
        addChild(myBidsViewController)
        
        contentView.addSubview(myBidsViewController.view)
        
        myBidsViewController.view.snp.makeConstraints { make in
            make.top.equalTo(auctionDetailView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        myBidsViewController.didMove(toParent: self)
    }
    
    // View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pollingOperation = PollingOperation(interval: 5.0) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.fetchActiveAuction()
            strongSelf.fetchAuctionDetails()
            strongSelf.fetchChartValues()
            
            strongSelf.pollMyBidsIfNeeded()
        }
        
        pollingOperation?.start()
    }
    
    private func fetchActiveAuction() {
        api?.fetchActiveAuction { _ in
            
        }
    }
    
    private func fetchAuctionDetails() {
        api?.fetchAuctionDetails(with: "") { _ in
            
        }
    }
    
    private func fetchChartValues() {
        api?.fetchChartData(for: "") { _ in
            
        }
    }
    
    private func pollMyBidsIfNeeded() {
        myBidsViewController.fetchMyBids()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pollingOperation?.invalidate()
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
