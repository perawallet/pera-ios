//
//  AccountsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccounsViewModel {
    func configure(_ cell: AssetCell, with assetDetail: AssetDetail, and asset: Asset) {
        cell.contextView.assetNameView.setAssetName(for: assetDetail)
        cell.contextView.amountLabel.text = asset.amount.assetAmount(fromFraction: assetDetail.fractionDecimals)
            .toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
    }
    
    func configure(_ cell: PendingAssetCell, with assetDetail: AssetDetail, isRemoving: Bool) {
        cell.contextView.pendingSpinnerView.show()
        cell.contextView.assetNameView.setAssetName(for: assetDetail)
        if isRemoving {
            cell.contextView.detailLabel.text = "asset-remove-confirmation-title".localized
        } else {
            cell.contextView.detailLabel.text = "asset-add-confirmation-title".localized
        }
    }
    
    func configure(_ cell: AlgoAssetCell, with account: Account) {
        cell.contextView.amountLabel.text = account.amount.toAlgos.toDecimalStringForLabel
    }
}

extension AccounsViewModel {
    func configure(_ header: AccountHeaderSupplementaryView, with account: Account) {
        header.contextView.setOptionsButton(hidden: false)
        
        if let accountInformation = UIApplication.shared.appConfiguration?.session.accountInformation(from: account.address),
            accountInformation.type == .ledger {
            header.contextView.setLedgerAccount()
        } else {
            header.contextView.setStandardAccount()
        }
        
        guard let accountName = account.name else {
            return
        }
        
        header.contextView.setAccountName(accountName.uppercased())
    }
}
