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
    
    func configureMaxPriceView(_ view: MaximumPriceView, with auction: Auction) {
        if let maximumPriceMultiple = auction.maximumPriceMultiple,
            let lastPrice = auction.lastPrice {
            let maxPrice = lastPrice * maximumPriceMultiple
            
            view.priceAmountTextField.attributedPlaceholder = NSAttributedString(
                string: "\(maxPrice.convertToDollars())",
                attributes: [NSAttributedString.Key.foregroundColor: SharedColors.darkGray,
                             NSAttributedString.Key.font: UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0))]
            )
        }
    }
}
