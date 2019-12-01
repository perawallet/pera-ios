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
                guard let assetIndex = assetDetail.index,
                    let asset = account.assets?[assetIndex] else {
                        return
                }
                
                let amountText = "\(Double(asset.amount).toDecimalStringForLabel ?? "")".attributed([.textColor(SharedColors.black)])
                cell.contextView.detailLabel.attributedText = amountText + "(\(assetDetail.unitName ?? ""))".attributed()
            } else {
                cell.contextView.detailLabel.text = account.amount.toAlgos.toDecimalStringForLabel
            }
        }
    }
}
