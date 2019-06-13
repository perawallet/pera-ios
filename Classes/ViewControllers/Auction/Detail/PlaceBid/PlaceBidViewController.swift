//
//  PlaceBidViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Crypto

protocol PlaceBidViewControllerDelegate: class {
    
    func placeBidViewControllerDidPlacedBid(_ placeBidViewController: PlaceBidViewController)
}

class PlaceBidViewController: BaseViewController {
    
    private let viewModel = PlaceBidViewModel()
    
    var auction: Auction
    var user: AuctionUser
    var auctionStatus: ActiveAuction
    
    weak var delegate: PlaceBidViewControllerDelegate?
    
    // MARK: Components
    
    private(set) lazy var placeBidView: PlaceBidView = {
        let view = PlaceBidView()
        return view
    }()
    
    // MARK: Initialization
    
    init(auction: Auction, user: AuctionUser, auctionStatus: ActiveAuction, configuration: ViewControllerConfiguration) {
        self.auction = auction
        self.user = user
        self.auctionStatus = auctionStatus
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        placeBidView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        viewModel.configureBidAmountView(placeBidView.bidAmountView, with: user, shouldUpdateValue: true)
        viewModel.configureMaxPriceView(placeBidView.maxPriceView, with: auctionStatus)
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
    
    func updateBidAmountViewForPolling() {
        viewModel.configureBidAmountView(placeBidView.bidAmountView, with: user)
    }
    
    func updateMaxPriceViewForPolling() {
        viewModel.configureMaxPriceView(placeBidView.maxPriceView, with: auctionStatus)
    }
}

// MARK: PlaceBidViewDelegate

extension PlaceBidViewController: PlaceBidViewDelegate {
    
    func placeBidViewDidTapPlaceBidButton(_ placeBidView: PlaceBidView) {
        guard auctionStatus.isBiddable(),
            let bidderAddress = user.address,
            var bidAmount = parseBidAmount(),
            let maxPrice = parseMaxPrice() else {
                return
        }
        
        let bidId = Int64(Date().timeIntervalSince1970)
        let auctionAddress = auction.auctionAddress
        let auctionId = Int64(auction.id)
        
        if let remainingAlgos = auctionStatus.remainingAlgos {
            let calculatedAlgos = bidAmount / maxPrice
            
            if remainingAlgos.toAlgos < calculatedAlgos {
                bidAmount = remainingAlgos.toAlgos * maxPrice
            }
        }
        
        let bidAmountIntValue = Int64(bidAmount * 1000000 * 100)
        let maxPriceIntValue = Int64(maxPrice * 100)
        
        var signedBidError: NSError?
        guard let bidData = AuctionMakeBid(
            bidderAddress,
            bidAmountIntValue,
            maxPriceIntValue,
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
                displaySimpleAlertWith(title: "title-error".localized, message: "auction-bid-coinlist-account-existence-error".localized)
                return
        }
        
        let bidString = signedBidData.base64EncodedString()
        
        placeBidView.placeBidButton.buttonState = .loading
        
        api?.placeBid(with: bidString, for: "\(auction.id)") { response in
            switch response {
            case .success:
                self.delegate?.placeBidViewControllerDidPlacedBid(self)
                
                let bidderUser = self.user
                
                if let availableAmount = bidderUser.availableAmount {
                    bidderUser.availableAmount = availableAmount - Int(bidAmountIntValue)
                    self.viewModel.configureBidAmountView(placeBidView.bidAmountView, with: bidderUser)
                }
                
                self.placeBidView.placeBidButton.buttonState = .normal
            case let .failure(error):
                self.displaySimpleAlertWith(title: "title-error".localized, message: error.localizedDescription)
                self.placeBidView.placeBidButton.buttonState = .normal
            }
        }
    }
    
    private func parseBidAmount() -> Double? {
        guard let bidAmountText = placeBidView.bidAmountView.bidAmountTextField.text, !bidAmountText.isEmpty else {
            return nil
        }
        
        guard let doubleValue = bidAmountText.doubleForReadSeparator else {
            return nil
        }
        
        return doubleValue
    }
    
    private func parseMaxPrice() -> Double? {
        var maxPriceText: String
        
        if let text = placeBidView.maxPriceView.priceAmountTextField.text, !text.isEmpty {
            maxPriceText = text
        } else if let currentPrice = auctionStatus.currentPrice {
            maxPriceText = "\(Double(currentPrice) / 100)"
        } else {
            return nil
        }
        
        guard let doubleValue = maxPriceText.doubleForSendSeparator else {
            return nil
        }
        
        return doubleValue
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
        
        viewModel.update(placeBidView, for: bidAmount, and: maxPrice, in: auctionStatus)
    }
}
