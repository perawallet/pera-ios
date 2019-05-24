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
        let maximumIndex = (auction.firstRound ?? 1) + (auction.priceChunkRounds ?? 1) * (auction.chunkCount ?? 1) - 1
        let view = AuctionDetailView(maximumIndex: Double(maximumIndex))
        return view
    }()
    
    private var auction: Auction
    private var user: AuctionUser
    private var activeAuction: ActiveAuction
    
    private var chartValues = [ChartData]()
    
    private var pollingOperation: PollingOperation?
    
    private let viewModel = AuctionDetailViewModel()
    
    private var keyboardController = KeyboardController()
    
    private lazy var placeBidViewController = PlaceBidViewController(
        auction: auction,
        user: user,
        activeAuction: activeAuction,
        configuration: configuration
    )
    
    private lazy var myBidsViewController = MyBidsViewController(
        auction: auction,
        user: user,
        activeAuction: activeAuction,
        configuration: configuration
    )
    
    // MARK: Initialization
    
    init(auction: Auction, user: AuctionUser, activeAuction: ActiveAuction, configuration: ViewControllerConfiguration) {
        self.auction = auction
        self.user = user
        self.activeAuction = activeAuction
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "auction-detail-title".localized
        
        scrollView.keyboardDismissMode = .onDrag
        
        viewModel.configure(auctionDetailView, with: auction, and: activeAuction)
    }
    
    override func linkInteractors() {
        auctionDetailView.delegate = self
        keyboardController.dataSource = self
    }
    
    override func setListeners() {
        super.setListeners()
        
        keyboardController.beginTracking()
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupAuctionDetailViewLayout()
        
        addPlaceBidViewController()
    }
    
    private func setupAuctionDetailViewLayout() {
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
        api?.fetchActiveAuction { response in
            switch response {
            case let .success(activeAuction):
                self.activeAuction = activeAuction
                self.placeBidViewController.activeAuction = activeAuction
                self.myBidsViewController.activeAuction = activeAuction
                
                self.viewModel.configure(self.auctionDetailView, with: self.auction, and: self.activeAuction)
                self.placeBidViewController.updateViewForPolling()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func fetchAuctionDetails() {
        api?.fetchAuctionDetails(with: "\(auction.id)") { response in
            switch response {
            case let .success(auction):
                self.auction = auction
                self.placeBidViewController.auction = auction
                self.myBidsViewController.auction = auction
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func fetchChartValues() {
        api?.fetchChartData(for: "\(auction.id)") { response in
            switch response {
            case let .success(values):
                self.chartValues = values
            case let .failure(error):
                print(error)
            }
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

// MARK: KeyboardControllerDataSource

extension AuctionDetailViewController: KeyboardControllerDataSource {
    
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return placeBidViewController.placeBidView.maxPriceView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
}
