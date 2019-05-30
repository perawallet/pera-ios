//
//  MyBidsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MyBidsViewModel {
    
    func configure(_ cell: BidCell, with bid: Bid) {
        if let status = bid.status {
            switch status {
            case .accepted,
                 .successful,
                 .paid:
                cell.contextView.bidStatusLabel.textColor = SharedColors.green
                cell.contextView.bidStatusLabel.text = status.rawValue
            case .retracted:
                cell.contextView.bidStatusLabel.textColor = SharedColors.darkGray
                cell.contextView.bidStatusLabel.text = status.rawValue
            case .unsuccessful:
                cell.contextView.bidStatusLabel.textColor = SharedColors.red
                cell.contextView.bidStatusLabel.text = "auction-detail-status-rejected-title".localized
            default:
                cell.contextView.bidStatusLabel.textColor = SharedColors.softGray
                cell.contextView.bidStatusLabel.text = status.rawValue
            }
        }
        
        guard let amount = bid.amount,
            let maxPrice = bid.maxPrice else {
                return
        }
        
        cell.contextView.amountLabel.text = "\((amount / 1000000).convertToDollars())"
        cell.contextView.maxPriceLabel.text = "@ \(maxPrice.convertToDollars())"
        cell.contextView.algosAmountLabel.text = Int64(((amount / 100) / (maxPrice / 100))).toAlgos.toDecimalStringForLabel
    }
    
    func configure(_ view: MyBidsView, with bids: [Bid], for emptyStateView: EmptyStateView) {
        if bids.isEmpty {
            view.totalPotentialAlgosDisplayView.backgroundColor = SharedColors.softGray.withAlphaComponent(0.8)
            view.myBidsCollectionView.contentState = .empty(emptyStateView)
            view.myBidsCollectionView.backgroundColor = .clear
            return
        }
        
        view.myBidsCollectionView.contentState = .none
        view.myBidsCollectionView.backgroundColor = .clear
        view.totalPotentialAlgosDisplayView.backgroundColor = SharedColors.blue
        
        let totalAmount = bids.reduce(0) {
            guard let amount = $1.amount,
                let maxPrice = $1.maxPrice else {
                    return 0
            }
            
            let total = ((amount / 100) * (maxPrice / 100))
            return $0 + total
        }
        
        view.totalPotentialAlgosDisplayView.amountLabel.text = Int64(totalAmount).toAlgos.toDecimalStringForLabel
    }
}
