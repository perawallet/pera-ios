//
//  PlaceBidViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PlaceBidViewModel {
    
    func configureBidAmountView(_ view: BidAmountView, with user: AuctionUser, shouldUpdateValue: Bool = false) {
        if let availableAmount = user.availableAmount {
            if shouldUpdateValue {
                if let amount = availableAmount.convertToDollars().currencyBidInputFormatting() {
                    view.bidAmountTextField.text = "\(amount) )"
                    view.auctionSliderView.configureViewForHundredPercentValue(updatesSliderValue: true)
                }
            }
            
            if let availableAmount = availableAmount.convertToDollars().currencyBidInputFormatting() {
                view.availableAmountLabel.text = "/ \(availableAmount)"
            }
        }
    }
    
    func configureMaxPriceView(_ view: MaximumPriceView, with auctionStatus: ActiveAuction) {
        guard let typedString = view.priceAmountTextField.text,
            let typedValue = typedString.doubleForSendSeparator,
            !typedString.isEmpty else {
                if let currentPrice = auctionStatus.currentPrice {
                    view.currentPrice = currentPrice
                    view.priceAmountTextField.attributedPlaceholder = NSAttributedString(
                        string: "\(currentPrice.convertToDollars())",
                        attributes: [NSAttributedString.Key.foregroundColor: SharedColors.darkGray,
                                     NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .bold(size: 13.0))]
                    )
                }
            return
        }
        
        if let currentPrice = auctionStatus.currentPrice {
            let typedPrice = Int(typedValue * 100)
            
            if currentPrice < typedPrice {
                view.currentPrice = currentPrice
                view.priceAmountTextField.text = currentPrice.convertToDollars()
            }
        }
    }
    
    func update(_ placeBidView: PlaceBidView, for bidAmount: Double, and maxPrice: Double, in auctionStatus: ActiveAuction) {
        if auctionStatus.isBiddable() {
            placeBidView.placeBidButton.isEnabled = true
        } else {
            placeBidView.placeBidButton.isEnabled = false
            if let zeroValue = (0.0).toDecimalStringForLabel {
                placeBidView.minPotentialAlgosView.amountLabel.text = "\(zeroValue)"
            }
            return
        }
        
        if let remainingAlgos = auctionStatus.remainingAlgos {
            let calculatedAlgos = bidAmount / maxPrice
            
            if remainingAlgos.toAlgos < calculatedAlgos {
                placeBidView.minPotentialAlgosView.amountLabel.text = remainingAlgos.toAlgos.toDecimalStringForLabel
            } else {
                placeBidView.minPotentialAlgosView.amountLabel.text = ((bidAmount) / (maxPrice)).toDecimalStringForLabel
            }
        }
    }
}
