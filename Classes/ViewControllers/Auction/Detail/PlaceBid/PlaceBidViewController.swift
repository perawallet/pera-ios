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
    
    private let localAuthenticator = LocalAuthenticator()
    
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
    
    func updateBidButtonForPolling() {
        if parseBidAmount() == 0 || parseMaxPrice() == 0 {
            placeBidView.placeBidButton.isEnabled = false
            placeBidView.minPotentialAlgosView.configureViewForZeroValue()
            return
        }
        
        if !auctionStatus.isBiddable() {
            placeBidView.minPotentialAlgosView.configureViewForZeroValue()
        }
    
        placeBidView.placeBidButton.isEnabled = auctionStatus.isBiddable()
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
            let bidAmount = parseBidAmount(),
            let maxPrice = parseMaxPrice() else {
                return
        }
        
        if maxPrice == 0 {
            displaySimpleAlertWith(title: "title-error".localized, message: "auction-bid-zero-max-price-error".localized)
            return
        }
        
        if bidAmount == 0 {
            displaySimpleAlertWith(title: "title-error".localized, message: "auction-bid-zero-bid-amount-error".localized)
            return
        }
        
        if let lastPrice = auction.lastPrice {
            if maxPrice * 100 < Double(lastPrice) {
                let localizedString = "auction-bid-min-max-price-error".localized
                let formattedPrice = lastPrice.convertToDollars()
                let message = String(format: localizedString, "\(formattedPrice)")
                displaySimpleAlertWith(title: "title-error".localized, message: message)
                return
            }
        }
        
        let potentialAlgos = bidAmount / maxPrice
        
        if let minimumAlgos = auction.minimumBidAlgos {
            if potentialAlgos < minimumAlgos.toAlgos {
                let localizedString = "auction-bid-potential-algo-error".localized
                
                if let formattedAlgos = minimumAlgos.toAlgos.toStringForTwoDecimal {
                    let message = String(format: localizedString, "\(formattedAlgos)")
                    displaySimpleAlertWith(title: "title-error".localized, message: message)
                }
                
                return
            }
        }
        
        if localAuthenticator.localAuthenticationStatus != .allowed {
            askForAppPassword()
            return
        }
        
        self.localAuthenticator.authenticate { error in
            guard error == nil else {
                self.askForAppPassword()
                return
            }
            
            self.placeBid(for: bidderAddress, with: bidAmount, and: maxPrice)
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
    
    private func askForAppPassword() {
        let controller = open(
            .choosePassword(
                mode: .confirm("auction-detail-bid-confirm-title".localized),
                route: nil),
            by: .present
        ) as? ChoosePasswordViewController
        
        controller?.delegate = self
    }
    
    private func placeBid(for bidderAddress: String, with amount: Double, and maxPrice: Double) {
        var bidAmount = amount
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
        
        guard let bidString = composeSignedBidString(from: bidData, for: bidderAddress) else {
            return
        }
        
        sendPlaceBidRequest(with: bidString, for: bidAmountIntValue)
    }
    
    private func composeSignedBidString(from bidData: Data, for bidderAddress: String) -> String? {
        var signedBidDataError: NSError?
        guard let privateData = session?.privateData(forAccount: bidderAddress),
            let signedBidData = CryptoSignBid(privateData, bidData, &signedBidDataError) else {
                displaySimpleAlertWith(title: "title-error".localized, message: "auction-bid-coinlist-account-existence-error".localized)
                return nil
        }
        
        return signedBidData.base64EncodedString()
    }
    
    private func sendPlaceBidRequest(with bidString: String, for bidAmountIntValue: Int64) {
        placeBidView.placeBidButton.buttonState = .loading
        
        api?.placeBid(with: bidString, for: "\(auction.id)") { response in
            switch response {
            case .success:
                self.delegate?.placeBidViewControllerDidPlacedBid(self)
                
                let bidderUser = self.user
                
                if let availableAmount = bidderUser.availableAmount {
                    bidderUser.availableAmount = availableAmount - Int(bidAmountIntValue)
                    self.viewModel.configureBidAmountView(self.placeBidView.bidAmountView, with: bidderUser)
                }
                
                self.placeBidView.placeBidButton.buttonState = .normal
            case let .failure(error):
                self.displaySimpleAlertWith(title: "title-error".localized, message: error.localizedDescription)
                self.placeBidView.placeBidButton.buttonState = .normal
            }
        }
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
                placeBidView.minPotentialAlgosView.configureViewForZeroValue()
                return
        }
        
        viewModel.update(placeBidView, for: bidAmount, and: maxPrice, in: auctionStatus)
    }
}

// MARK: ChoosePasswordViewControllerDelegate

extension PlaceBidViewController: ChoosePasswordViewControllerDelegate {
    
    func choosePasswordViewController(_ choosePasswordViewController: ChoosePasswordViewController, didConfirmPassword isConfirmed: Bool) {
        if isConfirmed {
            guard auctionStatus.isBiddable(),
                let bidderAddress = user.address,
                let bidAmount = parseBidAmount(),
                let maxPrice = parseMaxPrice() else {
                    return
            }
            
            placeBid(for: bidderAddress, with: bidAmount, and: maxPrice)
        } else {
            displaySimpleAlertWith(
                title: "password-verify-fail-title".localized,
                message: "options-view-passphrase-password-alert-message".localized
            )
        }
    }
}
