//
//  RekeyConfirmationViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 5.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

class RekeyConfirmationViewModel {
    
    private var assetText: String?
    private var oldTransitionTitle: String?
    private var oldTransitionValue: String?
    private var newTransitionValue: String?
    private var feeValue: String?
    
    init(account: Account, ledgerName: String?) {
        setAssetCount(for: account)
        setOldTransitionTitle(for: account)
        setOldTransitionValue(for: account)
        setNewTransitionValue(with: ledgerName)
        setFeeValue()
    }
    
    private func setAssetCount(for account: Account) {
        if account.assetDetails.count > 1 {
            assetText = "ledger-rekey-more-assets".localized(params: "\(account.assetDetails.count - 1)")
        }
    }
    
    private func setOldTransitionTitle(for account: Account) {
        if account.type.requiresLedgerConnection() {
            oldTransitionTitle = "ledger-rekey-ledger-old".localized
        } else {
            oldTransitionTitle = "ledger-rekey-ledger-passphrase".localized
        }
    }
    
    private func setOldTransitionValue(for account: Account) {
        if account.type.requiresLedgerConnection() {
            if let ledgerName = account.ledgerDetail?.name {
                oldTransitionValue = ledgerName
            } else {
                oldTransitionValue = account.name
            }
        } else {
            oldTransitionValue = "*********"
        }
    }
    
    private func setNewTransitionValue(with ledgerName: String?) {
        newTransitionValue = ledgerName
    }
    
    private func setFeeValue() {
        /// <todo> This calculation will be updated when its details are clear.
        let fee = max(Int64(minimumFee), Int64(50) * Int64(1))
        feeValue = "ledger-rekey-total-fee".localized(params: "\(fee)")
    }
}

extension RekeyConfirmationViewModel {
    func configure(_ view: RekeyConfirmationView) {
        view.setTransitionOldTitleLabel(oldTransitionTitle)
        view.setTransitionOldValueLabel(oldTransitionValue)
        view.setTransitionNewValueLabel(newTransitionValue)
        view.setFeeAmount(feeValue)
    }
    
    func configure(_ view: RekeyConfirmationFooterSupplementaryView) {
        view.contextView.setMoreAssetsButtonTitle(assetText)
    }
}
