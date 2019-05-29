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
    var user: AuctionUser
    var activeAuction: ActiveAuction
    
    // MARK: Components
    
    private(set) lazy var placeBidView: PlaceBidView = {
        let view = PlaceBidView()
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
    
    override func linkInteractors() {
        placeBidView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        viewModel.configureBidAmountView(placeBidView.bidAmountView, with: user)
        viewModel.configureMaxPriceView(placeBidView.maxPriceView, with: activeAuction)
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
    
    func updateViewForPolling() {
        viewModel.configureMaxPriceView(placeBidView.maxPriceView, with: activeAuction)
    }
}

// MARK: PlaceBidViewDelegate

extension PlaceBidViewController: PlaceBidViewDelegate {
    
    func placeBidViewDidTapPlaceBidButton(_ placeBidView: PlaceBidView) {
        guard let bidderAddress = session?.currentAccount?.address,
            let bidAmount = parseBidAmount(),
            let maxPrice = parseMaxPrice() else {
                return
        }
        
        let bidId = Int64(Date().timeIntervalSince1970)
        let auctionAddress = auction.auctionAddress
        let auctionId = Int64(auction.id)
        
        var signedBidError: NSError?
        guard let bidData = AuctionMakeBid(
            bidderAddress,
            bidAmount * 1000000,
            maxPrice,
            bidId,
            auctionAddress,
            auctionId,
            &signedBidError
        ) else {
            return
        }
        
        var signedBidDataError: NSError?
        guard let privateData = session?.privateData(forAccount: bidderAddress),
            let signedBidData = CryptoSignBid(privateData, bidData, &signedBidDataError) else {
                return
        }
        
        let bidString = signedBidData.base64EncodedString()
        
        placeBidView.placeBidButton.buttonState = .loading
        
        api?.placeBid(with: bidString, for: "\(auction.id)") { response in
            switch response {
            case let .success(bidResponse):
                print(bidResponse)
            case let .failure(error):
                print(error)
            }
            
            self.placeBidView.placeBidButton.buttonState = .normal
        }
    }
    
    private func parseBidAmount() -> Int64? {
        guard var bidAmountText = placeBidView.bidAmountView.bidAmountTextField.text, !bidAmountText.isEmpty else {
            return nil
        }
        
        if bidAmountText.contains("$") {
            bidAmountText = String(bidAmountText.dropFirst())
        }
        
        var shouldMultipleForCents = false
        
        if !bidAmountText.contains(".") && !bidAmountText.contains(",") {
            shouldMultipleForCents = true
        }
        
        bidAmountText = bidAmountText.filter { character -> Bool in
            character != "," && character != "."
        }
        
        guard let bidAmountValue = Int64(bidAmountText) else {
            return nil
        }
        
        if shouldMultipleForCents {
            return bidAmountValue * 100
        }
        
        return bidAmountValue
    }
    
    private func parseMaxPrice() -> Int64? {
        var maxPriceText: String
        
        if let text = placeBidView.maxPriceView.priceAmountTextField.text, !text.isEmpty {
            maxPriceText = text
        } else if let currentPrice = activeAuction.currentPrice {
            maxPriceText = "\(currentPrice / 100)"
        } else {
            return nil
        }
        
        if maxPriceText.contains("$") {
            maxPriceText = String(maxPriceText.dropFirst())
        }
        
        maxPriceText = maxPriceText.filter { character -> Bool in
            character != "," && character != "."
        }
        
        guard let maxPriceValue = Int64(maxPriceText) else {
            return nil
        }
        
        return maxPriceValue * 100
    }
    
    func placeBidView(_ placeBidView: PlaceBidView, didChangeSlider value: Float) {
        guard let availableAmount = user.availableAmount else {
            return
        }
        
        let amount = availableAmount * Int(value) / 100
        
        placeBidView.bidAmountView.bidAmountTextField.text = "\(amount.convertToDollars())"
        
        calculatePotentialAlgos()
    }
    
    func placeBidViewDidTypeInput(_ placeBidView: PlaceBidView, in textField: UITextField) {
        calculatePotentialAlgos()
    }
    
    private func calculatePotentialAlgos() {
        guard let bidAmount = parseBidAmount(),
            let maxPrice = parseMaxPrice(),
            bidAmount != 0,
            maxPrice != 0 else {
                placeBidView.placeBidButton.isEnabled = false
                return
        }
        
        viewModel.update(placeBidView, for: bidAmount, and: maxPrice, in: activeAuction)
    }
}
