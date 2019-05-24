//
//  AuctionDetailViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionDetailViewModel {
    
    func configure(_ view: AuctionDetailView, with auction: Auction, and activeAuction: ActiveAuction) {
        if let currentPrice = activeAuction.currentPrice {
            view.auctionDetailHeaderView.auctionChartView.currentValueLabel.text = currentPrice.convertToDollars(withSymbol: false)
        }
        
        view.auctionDetailHeaderView.timerView.mode = .initial
        
        if let finishTime = activeAuction.estimatedFinishTime {
            view.auctionDetailHeaderView.timerView.time = finishTime.timeIntervalSinceNow
            
            if finishTime.timeIntervalSinceNow < 0 {
                view.auctionDetailHeaderView.timerView.stopTimer()
            }
        }
        
        view.auctionDetailHeaderView.timerView.runTimer()
        
        if let remainingAlgos = activeAuction.remainingAlgos?.toAlgos,
            let totalAlgos = auction.algos?.toAlgos {
            view.auctionDetailHeaderView.remainingAlgosView.algosAmountView.amountLabel.text = remainingAlgos.toDecimalStringForLabel
            view.auctionDetailHeaderView.remainingAlgosView.algosAmountView.amountLabel.textColor = SharedColors.blue
            view.auctionDetailHeaderView.remainingAlgosView.algosAmountView.algoIconImageView.image = img("icon-algo-small-blue")
            
            view.auctionDetailHeaderView.remainingAlgosView.percentageLabel.text = "(\(Int(remainingAlgos * 100 / totalAlgos))%)"
        }
    }
}
