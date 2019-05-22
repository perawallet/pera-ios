//
//  PlaceBidViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Crypto

class PlaceBidViewController: BaseViewController {
    
    private let viewModel = PlaceBidViewModel()
    
    var auction: Auction
    var activeAuction: ActiveAuction
    
    // MARK: Components
    
    private(set) lazy var placeBidView: PlaceBidView = {
        let view = PlaceBidView()
        return view
    }()
    
    // MARK: Initialization
    
    init(auction: Auction, activeAuction: ActiveAuction, configuration: ViewControllerConfiguration) {
        self.auction = auction
        self.activeAuction = activeAuction
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        placeBidView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupPlaceBidViewLayout()
    }
    
    private func setupPlaceBidViewLayout() {
        view.addSubview(placeBidView)
        
        placeBidView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

// MARK: PlaceBidViewDelegate

extension PlaceBidViewController: PlaceBidViewDelegate {
    
    func placeBidViewDidTapPlaceBidButton(_ placeBidView: PlaceBidView) {
        placeBid()
    }
    
    private func placeBid() {
        let bidderAddress: String? = nil
        let bidAmount: Int64 = 0
        let maxPrice: Int64 = 0
        let bidId: Int64 = 0
        let auctionAddress: String? = nil
        let auctionId = Int64(auction.id)
        
        var signedBidError: NSError?
        
        guard let bidData = AuctionMakeBid(bidderAddress, bidAmount, maxPrice, bidId, auctionAddress, auctionId, &signedBidError) else {
            return
        }
        
        let bidString = bidData.base64EncodedString()
        
        api?.placeBid(with: bidString, for: "\(auction.id)") { response in
            switch response {
            case let .success(bidResponse):
                print(bidResponse)
            case let .failure(error):
                print(error)
            }
        }
    }
}
