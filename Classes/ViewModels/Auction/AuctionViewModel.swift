//
//  AuctionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SwiftDate

class AuctionViewModel {
    
    func configure(_ cell: ActiveAuctionCell, with activeAuction: ActiveAuction) {
        cell.contextView.dateView.detailLabel.text = activeAuction.estimatedAuctionRoundStart?.toFormat("MMMM dd, yyyy")
        
        if let status = activeAuction.status {
            switch status {
            case .announced:
                cell.contextView.auctionTimerView.mode = .initial
                
                if let startTime = activeAuction.estimatedAuctionRoundStart {
                    cell.contextView.auctionTimerView.time = startTime.timeIntervalSinceNow
                }
            case .running:
                cell.contextView.auctionTimerView.mode = .active
                
                if let finishTime = activeAuction.estimatedFinishTime {
                    cell.contextView.auctionTimerView.time = finishTime.timeIntervalSinceNow
                }
            case .closed:
                cell.contextView.auctionTimerView.mode = .ended
            case .settled:
                break
            }
            
            cell.contextView.auctionTimerView.runTimer()
            
            cell.contextView.status = status
        }
        
        if let price = activeAuction.currentPrice {
            cell.contextView.priceView.detailLabel.text = convertToDollars(price)
        }
        
        if let remainingAlgos = activeAuction.remainingAlgos?.toAlgos {
            cell.contextView.remainingAlgosView.algosAmountView.amountLabel.text = remainingAlgos.toDecimalStringForLabel
            cell.contextView.remainingAlgosView.algosAmountView.amountLabel.textColor = SharedColors.blue
            cell.contextView.remainingAlgosView.algosAmountView.algoIconImageView.image = img("icon-algo-small-blue")
            
            if activeAuction.totalAlgos == 0 {
                if remainingAlgos == 0 {
                    cell.contextView.remainingAlgosView.percentageLabel.text = "(0%)"
                } else {
                    cell.contextView.remainingAlgosView.percentageLabel.text = "(\(Int(remainingAlgos * 100 / remainingAlgos))%)"
                }
            } else {
                cell.contextView.remainingAlgosView.percentageLabel.text =
                    "(\(Int(remainingAlgos * 100 / activeAuction.totalAlgos.toAlgos))%)"
            }
        }
    }
    
    func convertToDollars(_ value: Int) -> String {
        let doubleValue = Double(value / 100)
        let formatter = NumberFormatter()
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currencyAccounting
        return formatter.string(from: NSNumber(value: doubleValue)) ?? "$\(doubleValue)"
    }
    
    func configureRemainingAlgosPercentage(in cell: ActiveAuctionCell, with activeAuction: ActiveAuction) {
        if let remainingAlgos = activeAuction.remainingAlgos?.toAlgos {
            cell.contextView.remainingAlgosView.percentageLabel.text = "(\(Int(remainingAlgos * 100 / activeAuction.totalAlgos.toAlgos))%)"
        }
    }
    
    func configure(_ cell: AuctionCell, with auction: Auction, and activeAuction: ActiveAuction?) {
        if let activeAuction = activeAuction {
            if let firstRound = auction.firstRound {
                let formattedDate = findDate(to: firstRound, from: activeAuction.currentRound).toFormat("MMMM dd, yyyy")
                cell.contextView.dateLabel.text = formattedDate
            }
        } else {
            if let firstRound = auction.firstRound {
                let formattedDate = findDate(to: firstRound, from: auction.firstRound).toFormat("MMMM dd, yyyy")
                cell.contextView.dateLabel.text = formattedDate
            }
        }
        
        if let algos = auction.algos {
            cell.contextView.algosAmountLabel.text = algos.toAlgos.toDecimalStringForLabel
        }
    }
    
    private func findDate(to round: Int, from lastRound: Int?) -> Date {
        guard let lastRound = lastRound else {
            return Date()
        }
        
        let roundDifference = lastRound - round
        let minuteDifference = roundDifference / 12
        
        if roundDifference <= 0 {
            return Date()
        }
        
        guard let auctionDate = Calendar.current.date(byAdding: .minute, value: Int(-minuteDifference), to: Date()) else {
            return Date()
        }
        
        return auctionDate
    }
}
