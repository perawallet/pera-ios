//
//  MyBidsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MyBidsViewModel {
    
    func configure(_ cell: LimitOrderCell, with bid: Bid) {
        configure(cell.contextView, with: bid)
    }
    
    func configure(_ cell: BidCell, with bid: Bid) {
        configure(cell.contextView, with: bid)
    }
    
    private func configure(_ view: BidCellContextView, with bid: Bid) {
        if let status = bid.status {
            switch status {
            case .accepted,
                 .successful,
                 .paid:
                view.bidStatusLabel.textColor = SharedColors.turquois
                view.bidStatusLabel.text = status.rawValue
                view.algoIconImageView.tintColor = SharedColors.turquois
                view.algosAmountLabel.textColor = SharedColors.turquois
            case .retracted:
                view.bidStatusLabel.textColor = SharedColors.orange
                view.bidStatusLabel.text = status.rawValue
                view.algoIconImageView.tintColor = SharedColors.orange
                view.algosAmountLabel.textColor = SharedColors.orange
            case .unsuccessful:
                view.bidStatusLabel.textColor = SharedColors.darkGray
                view.bidStatusLabel.text = "auction-detail-status-rejected-title".localized
                view.algoIconImageView.tintColor = SharedColors.darkGray
                view.algosAmountLabel.textColor = SharedColors.darkGray
            default:
                view.bidStatusLabel.textColor = SharedColors.black
                view.bidStatusLabel.text = status.rawValue
                view.algoIconImageView.tintColor = SharedColors.black
                view.algosAmountLabel.textColor = SharedColors.black
            }
        }
        
        guard let amount = bid.amount,
            let maxPrice = bid.maxPrice else {
                return
        }
        
        view.amountLabel.text = "\((amount / 1000000).convertToDollars())"
        view.maxPriceLabel.text = "@ \(maxPrice.convertToDollars())"
        view.algosAmountLabel.text = Int64((Double(amount) / Double(maxPrice))).toAlgos.toDecimalStringForLabel
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
        view.totalPotentialAlgosDisplayView.backgroundColor = SharedColors.purple
        
        let totalAmount = bids.reduce(0.0) {
            guard let amount = $1.amount,
                let maxPrice = $1.maxPrice else {
                    return 0
            }
            
            var total: Double = 0
            
            if $1.status != .retracted {
                total = (Double(amount) / Double(maxPrice))
            }
            
            return $0 + total
        }
        
        view.totalPotentialAlgosDisplayView.amountLabel.text = Int64(totalAmount).toAlgos.toDecimalStringForLabel
    }
}
