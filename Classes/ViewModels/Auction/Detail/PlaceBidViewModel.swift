//
//  PlaceBidViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PlaceBidViewModel {
    
    func configureBidAmountView(_ view: BidAmountView, with user: AuctionUser) {
        if let availableAmount = user.availableAmount {
            view.availableAmountLabel.text = "/ \(availableAmount.convertToDollars())"
        }
    }
    
    func configureMaxPriceView(_ view: MaximumPriceView, with activeAuction: ActiveAuction) {
        guard let typedValue = view.priceAmountTextField.text else {
            setInitialPrice(for: activeAuction, in: view)
            return
        }
        
        if typedValue.isEmpty {
            setInitialPrice(for: activeAuction, in: view)
        }
    }
    
    private func setInitialPrice(for activeAuction: ActiveAuction, in view: MaximumPriceView) {
        if let currentPrice = activeAuction.currentPrice {
            view.priceAmountTextField.attributedPlaceholder = NSAttributedString(
                string: "\(currentPrice.convertToDollars())",
                attributes: [NSAttributedString.Key.foregroundColor: SharedColors.darkGray,
                             NSAttributedString.Key.font: UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0))]
            )
        }
    }
    
    func update(_ placeBidView: PlaceBidView, for bidAmount: Int64, and maxPrice: Int64, in activeAuction: ActiveAuction) {
        if activeAuction.isBiddable() {
            placeBidView.placeBidButton.isEnabled = true
        }
        
        if let currentPrice = activeAuction.currentPrice,
            currentPrice > maxPrice {
            placeBidView.placeBidButton.setTitle("auction-detail-limit-order-button-title".localized, for: .normal)
        } else {
            placeBidView.placeBidButton.setTitle("auction-detail-place-bid-button-title".localized, for: .normal)
        }
        
        placeBidView.minPotentialAlgosView.amountLabel.text = ((bidAmount) / (maxPrice)).toDecimalStringForLabel
    }
}
