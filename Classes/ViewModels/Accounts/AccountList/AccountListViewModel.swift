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
        switch mode {
        case .assetCount:
            cell.contextView.detailLabel.text = "\(account.assetDetails.count) " + "contacts-title-assets".localized
        case let .amount(assetDetail):
            if let assetDetail = assetDetail {
                guard let assetAmount = account.amount(for: assetDetail)else {
                    return
                }
                
                let amountText = "\(assetAmount.toDecimalStringForLabel ?? "")".attributed([
                    .font(UIFont.font(.overpass, withWeight: .semiBold(size: 15.0))),
                    .textColor(SharedColors.black)
                ])
                let codeText = " (\(assetDetail.unitName ?? ""))".attributed([
                    .font(UIFont.font(.overpass, withWeight: .semiBold(size: 15.0))),
                    .textColor(SharedColors.purple)
                ])
                cell.contextView.detailLabel.attributedText = amountText + codeText
            } else {
                cell.contextView.detailLabel.text = account.amount.toAlgos.toDecimalStringForLabel
            }
        }
    }
}
