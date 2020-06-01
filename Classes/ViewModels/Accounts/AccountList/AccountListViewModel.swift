//
//  AccountListViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountListViewModel {
    func configure(_ cell: AccountViewCell, with account: Account, for mode: AccountListViewController.Mode) {
        cell.contextView.nameLabel.text = account.name
        
        if account.type.isLedger() {
            cell.contextView.setAccountTypeImage(img("icon-account-type-ledger"), hidden: false)
        } else {
            cell.contextView.setAccountTypeImage(img("icon-account-type-standard"), hidden: false)
        }
        
        switch mode {
        case .assetCount:
            cell.contextView.detailLabel.text = "\(account.assetDetails.count) " + "accounts-title-assets".localized
        case let .transactionSender(assetDetail),
             let .transactionReceiver(assetDetail),
             let .contact(assetDetail):
            if let assetDetail = assetDetail {
                guard let assetAmount = account.amount(for: assetDetail)else {
                    return
                }
                
                let amountText = "\(assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals) ?? "")".attributed([
                    .font(UIFont.font(withWeight: .medium(size: 14.0))),
                    .textColor(SharedColors.primaryText)
                ])
                
                let codeText = " (\(assetDetail.getAssetCode()))".attributed([
                    .font(UIFont.font(withWeight: .medium(size: 14.0))),
                    .textColor(SharedColors.detailText)
                ])
                cell.contextView.detailLabel.attributedText = amountText + codeText
            } else {
                cell.contextView.detailLabel.textColor = SharedColors.primaryText
                cell.contextView.imageView.isHidden = false
                cell.contextView.detailLabel.text = account.amount.toAlgos.toDecimalStringForLabel
            }
        }
    }
}
