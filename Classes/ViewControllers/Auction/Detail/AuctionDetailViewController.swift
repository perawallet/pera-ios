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
        let maximumIndex = (auction.priceChunkRounds ?? 1) * (auction.chunkCount ?? 1) - 1
        let initialValue = auction.algos?.toAlgos ?? 0
        let view = AuctionDetailView(initialValue: initialValue, maximumIndex: Double(maximumIndex))
        return view
    }()
    
    private var auction: Auction
    private var user: AuctionUser
    private var auctionStatus: ActiveAuction
    
    private var chartValues = [ChartData]()
    
    private var pollingOperation: PollingOperation?
    
    private var viewModel = AuctionDetailViewModel()
    
    private var keyboardController = KeyboardController()
    
    var isPollingEnabled: Bool {
        return true
    }
    
    private lazy var placeBidViewController = PlaceBidViewController(
        auction: auction,
        user: user,
        auctionStatus: auctionStatus,
        configuration: configuration
    )
    
    private lazy var myBidsViewController = MyBidsViewController(
        auction: auction,
        user: user,
        auctionStatus: auctionStatus,
        configuration: configuration
    )
    
    // MARK: Initialization
    
    init(auction: Auction, user: AuctionUser, auctionStatus: ActiveAuction, configuration: ViewControllerConfiguration) {
        self.auction = auction
        self.user = user
        self.auctionStatus = auctionStatus
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "auction-detail-title".localized
        
        scrollView.keyboardDismissMode = .onDrag
        
        if isPollingEnabled {
            viewModel.configure(auctionDetailView, with: auction, and: auctionStatus)
        } else {
            fetchAuctionDetail()
        }
    }
    
    override func linkInteractors() {
        auctionDetailView.delegate = self
        placeBidViewController.delegate = self
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
        
        if isPollingEnabled {
            pollingOperation = PollingOperation(interval: 5.0) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.fetchAuctionDetail()
            }
            
            pollingOperation?.start()
        }
    }
    
    private func fetchAuctionDetail() {
        fetchAuctionStatus()
        fetchAuctionDetails()
        fetchChartValues()
        fetchAuctionUser()
        fetchMyBids()
    }
    
    private func fetchAuctionStatus() {
        api?.fetchAuctionStatus(for: "\(auction.id)") { response in
            switch response {
            case let .success(auctionStatus):
                self.auctionStatus = auctionStatus
                self.placeBidViewController.auctionStatus = auctionStatus
                self.myBidsViewController.auctionStatus = auctionStatus
                
                self.viewModel.configure(self.auctionDetailView, with: self.auction, and: auctionStatus)
                
                self.placeBidViewController.updateMaxPriceViewForPolling()
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
                if self.chartValues.isEmpty {
                    self.chartValues = values
                    
                    var chartData = [ChartDataEntry]()
                    
                    for (index, value) in self.chartValues.enumerated() {
                        if let waitCount = self.auction.priceChunkRounds {
                            chartData.append(ChartDataEntry(x: Double(index * waitCount), y: Double(value.remainingAlgos ?? 1)))
                            
                            for i in 1..<waitCount {
                                if index == 0 {
                                    chartData.append(ChartDataEntry(x: Double(i),
                                                                    y: Double(value.remainingAlgos ?? 1)))
                                } else {
                                    chartData.append(ChartDataEntry(x: Double((index * waitCount) + i),
                                                                    y: Double(value.remainingAlgos ?? 1)))
                                }
                            }
                        }
                        
                    }
                    
                    self.auctionDetailView.auctionDetailHeaderView.auctionChartView.setData(
                        entries: chartData,
                        isCompleted: !self.isPollingEnabled
                    )
                    
                } else {
                    let arraySlice = values.suffix(values.count - self.chartValues.count)
                    let newArray = Array(arraySlice)
                    
                    var chartData = [ChartDataEntry]()
                    
                    for (index, value) in newArray.enumerated() {
                        if let waitCount = self.auction.priceChunkRounds {
                            chartData.append(ChartDataEntry(x: Double((self.chartValues.count + index) * waitCount),
                                                            y: Double(value.remainingAlgos ?? 1)))
                            for i in 1..<waitCount {
                                chartData.append(ChartDataEntry(x: Double(((self.chartValues.count + index) * waitCount) + i),
                                                                y: Double(value.remainingAlgos ?? 1)))
                            }
                        }
                    }
                    
                    if !newArray.isEmpty {
                        self.chartValues.append(contentsOf: newArray)
                        
                        self.auctionDetailView.auctionDetailHeaderView.auctionChartView
                            .addData(entries: chartData, at: self.chartValues.count + chartData.count)
                    }
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func fetchAuctionUser() {
        api?.fetchAuctionUser { response in
            switch response {
            case let .success(user):
                self.user = user
                self.placeBidViewController.user = user
                self.myBidsViewController.user = user
                
                self.placeBidViewController.updateBidAmountViewForPolling()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func fetchMyBids() {
        myBidsViewController.fetchMyBids {
            self.viewModel.configureMyBidsHeader(self.auctionDetailView, with: self.myBidsViewController.bids.count)
            self.viewModel.configureClosedState(self.auctionDetailView, with: self.myBidsViewController.bids, and: self.auctionStatus)
        }
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

extension AuctionDetailViewController: PlaceBidViewControllerDelegate {
    
    func placeBidViewControllerDidPlacedBid(_ placeBidViewController: PlaceBidViewController) {
        
    }
}

class PastAuctionDetailViewController: AuctionDetailViewController {
    
    override var isPollingEnabled: Bool {
        return false
    }
}
