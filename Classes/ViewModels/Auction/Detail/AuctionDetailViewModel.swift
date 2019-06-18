//
//  AuctionDetailViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionDetailViewModel {
    
    func configure(_ view: AuctionDetailView, with auction: Auction, and auctionStatus: ActiveAuction) {
        if let currentPrice = auctionStatus.currentPrice {
            view.auctionDetailHeaderView.auctionChartView.currentValueLabel.text =
                currentPrice.convertToDollars(withSymbol: false).currencyBidInputFormatting()
        }
        
        if let remainingAlgos = auctionStatus.remainingAlgos?.toAlgos,
            let totalAlgos = auction.algos?.toAlgos,
            auctionStatus.isBiddable() {
            view.auctionDetailHeaderView.remainingAlgosView.algosAmountView.amountLabel.text = remainingAlgos.toDecimalStringForLabel
            view.auctionDetailHeaderView.remainingAlgosView.algosAmountView.amountLabel.textColor = SharedColors.turquois
            view.auctionDetailHeaderView.remainingAlgosView.algosAmountView.algoIconImageView.image = img("icon-remaining-algo")
            
            if let percentage = (remainingAlgos * 100 / totalAlgos).toStringForTwoDecimal {
                view.auctionDetailHeaderView.remainingAlgosView.percentageLabel.text = "(\(percentage)%)"
            }
        }
        
        if let finishTime = auctionStatus.estimatedFinishTime, auctionStatus.isBiddable() {
            view.auctionDetailHeaderView.timerView.time = finishTime.timeIntervalSinceNow
            
            if finishTime.timeIntervalSinceNow <= 0 {
                view.auctionDetailHeaderView.timerView.mode = .ended
            } else {
                view.auctionDetailHeaderView.timerView.mode = .initial
            }
        }
        
        if !auctionStatus.isBiddable() {
            view.auctionDetailHeaderView.timerView.time = 0
            view.auctionDetailHeaderView.auctionChartView.configureCompletedState()
            view.auctionDetailHeaderView.timerView.mode = .ended
            view.auctionDetailHeaderView.isBiddable = false
        }
    }
    
    func configureMyBidsHeader(_ view: AuctionDetailView, with count: Int) {
        let title = "auction-detail-my-bids-title".localized + " (\(count))"
        view.myBidsButton.setTitle(title, for: .normal)
    }
    
    func configureClosedState(_ view: AuctionDetailView, with bids: [Bid], and auctionStatus: ActiveAuction) {
        if auctionStatus.isBiddable() {
            return
        }
        
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
        
        view.auctionDetailHeaderView.remainingAlgosView.explanationLabel.text = "auction-detail-total-algos-title".localized
        view.auctionDetailHeaderView.remainingAlgosView.percentageLabel.text = ""
        view.auctionDetailHeaderView.remainingAlgosView.algosAmountView.amountLabel.text
            = Int64(totalAmount).toAlgos.toDecimalStringForLabel
        
        view.auctionDetailHeaderView.remainingAlgosView.algosAmountView.algoIconImageView.image = img("algo-icon-min-purple")
        view.auctionDetailHeaderView.remainingAlgosView.algosAmountView.amountLabel.textColor = SharedColors.purple
        
        let bidAmount = bids.reduce(0.0) {
            guard let amount = $1.amount else {
                return 0
            }
            
            var doubleValue: Double = 0
            
            if $1.status != .retracted {
                doubleValue = Double(amount) / 100000000
            }
            
            return $0 + doubleValue
        }
        
        if let bidAmountValue = bidAmount.toDecimalStringForLabel {
            view.auctionDetailHeaderView.committedAmountView.detailLabel.text = "$\(bidAmountValue)"
        }
    }
}
