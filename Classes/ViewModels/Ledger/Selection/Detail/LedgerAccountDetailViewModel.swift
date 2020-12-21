//
//  LedgerAccountDetailViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountDetailViewModel {
    
    private(set) var subtitle: String?
    private(set) var assetViews: [UIView] = []
    private(set) var rekeyedAccountViews: [UIView]?
    
    init(account: Account, rekeyedAccounts: [Account]?) {
        setAssetViews(from: account)
        setSubtitle(from: account)
        setRekeyedAccountViews(from: account, and: rekeyedAccounts)
    }
    
    private func setAssetViews(from account: Account) {
        addLedgerInfoAccountNameView(for: account)
        addAlgoView(for: account)
        addAssetViews(for: account)
    }
    
    private func setSubtitle(from account: Account) {
        subtitle = account.isRekeyed() ? "Can be signed by" : "Can sign for these accounts"
    }
    
    private func setRekeyedAccountViews(from account: Account, and rekeyedAccounts: [Account]?) {
        if account.isRekeyed() {
            let roundedAccountNameView = RoundedAccountNameView()
            roundedAccountNameView.bind(AccountNameViewModel(account: account))
            rekeyedAccountViews = [roundedAccountNameView]
        } else {
            guard let rekeyedAccounts = rekeyedAccounts,
                  !rekeyedAccounts.isEmpty else {
                return
            }
            
            rekeyedAccountViews = []
            
            rekeyedAccounts.forEach { rekeyedAccount in
                let roundedAccountNameView = RoundedAccountNameView()
                roundedAccountNameView.bind(AccountNameViewModel(account: rekeyedAccount))
                rekeyedAccountViews?.append(roundedAccountNameView)
            }
        }
    }
}

extension LedgerAccountDetailViewModel {
    private func addLedgerInfoAccountNameView(for account: Account) {
        let ledgerInfoAccountNameView = LedgerInfoAccountNameView()
        ledgerInfoAccountNameView.bind(AccountNameViewModel(account: account))
        assetViews.append(ledgerInfoAccountNameView)
    }
    
    private func addAlgoView(for account: Account) {
        let algoView = AlgoAssetView()
        algoView.amountLabel.text = account.amount.toAlgos.toAlgosStringForLabel
        assetViews.append(algoView)
        
        if account.assets.isNilOrEmpty {
            algoView.setSeparatorHidden(true)
        }
    }
    
    private func addAssetViews(for account: Account) {
        for (index, assetDetail) in account.assetDetails.enumerated() {
            guard let asset = account.assets?[safe: index] else {
                continue
            }
            
            if assetDetail.isVerified {
                addVerifiedAssetViews(assetDetail: assetDetail, asset: asset)
            } else {
                addUnverifiedAssetViews(assetDetail: assetDetail, asset: asset)
            }
        }
    }
    
    private func addVerifiedAssetViews(assetDetail: AssetDetail, asset: Asset) {
        if assetDetail.hasBothDisplayName() {
            addAssetView(AssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyAssetName() {
            addAssetView(OnlyNameAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyUnitName() {
            addAssetView(OnlyUnitNameAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasNoDisplayName() {
            addAssetView(UnnamedAssetCell(), assetDetail: assetDetail, asset: asset)
        }
    }
    
    private func addUnverifiedAssetViews(assetDetail: AssetDetail, asset: Asset) {
        if assetDetail.hasBothDisplayName() {
            addAssetView(UnverifiedAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyAssetName() {
            addAssetView(UnverifiedOnlyNameAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyUnitName() {
            addAssetView(UnverifiedOnlyUnitNameAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasNoDisplayName() {
            addAssetView(UnverifiedUnnamedAssetCell(), assetDetail: assetDetail, asset: asset)
        }
    }
    
    private func addAssetView(_ view: BaseAssetCell, assetDetail: AssetDetail, asset: Asset) {
        let accountsViewModel = AccountsViewModel()
        accountsViewModel.configure(view, with: assetDetail, and: asset)
        assetViews.append(view)
    }
}
