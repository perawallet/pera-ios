//
//  RekeyConfirmationViewModel.swift

import Foundation

class RekeyConfirmationViewModel {
    
    private(set) var assetText: String?
    private(set) var oldTransitionTitle: String?
    private(set) var oldTransitionValue: String?
    private(set) var newTransitionValue: String?
    private(set) var feeValue: String?
    
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
        if account.requiresLedgerConnection() {
            oldTransitionTitle = "ledger-rekey-ledger-old".localized
        } else {
            oldTransitionTitle = "ledger-rekey-ledger-passphrase".localized
        }
    }
    
    private func setOldTransitionValue(for account: Account) {
        if account.requiresLedgerConnection() {
            if let ledgerName = account.currentLedgerDetail?.name {
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
        let fee = max(Int64(minimumFee), 0)
        feeValue = "ledger-rekey-total-fee".localized(params: "\(fee.toAlgos)")
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
