//
//  DepositViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class DepositViewModel {
    
    func configure(_ view: DepositView, for user: AuctionUser) {
        if let availableAmount = user.availableAmount?.convertToDollars() {
            view.balanceHeaderView.amountLabel.text = availableAmount
        }
    }
    
    func configure(_ view: DepositView, btcDepositInformation: BlockchainInstruction, ethDepositInformation: BlockchainInstruction) {
        if let btcRate = btcDepositInformation.rate {
            view.depositFundSelectionView.depositTypeSelectionView.btcDepositTypeView.amountLabel.text = "\(btcRate.convertToDollars())"
        }
        
        if let ethRate = ethDepositInformation.rate {
            view.depositFundSelectionView.depositTypeSelectionView.ethDepositTypeView.amountLabel.text = "\(ethRate.convertToDollars())"
        }
        
        if let time = btcDepositInformation.time {
            let date = Date(milliseconds: time)
            
            let formattedDate = date.toFormat("HH:mm 'on' MMMM dd, yyyy")
            let localizedString = "deposit-fund-convert-title".localized
            let dateLabel = String(format: localizedString, formattedDate)
            
            view.depositFundSelectionView.bottomExplanationLabel.text = dateLabel
        }
    }
}
