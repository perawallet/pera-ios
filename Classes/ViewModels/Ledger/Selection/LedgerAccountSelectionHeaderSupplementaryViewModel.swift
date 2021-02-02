//
//  LedgerAccountSelectionHeaderSupplementaryViewModel.swift

import Foundation

class LedgerAccountSelectionHeaderSupplementaryViewModel {
    
    private(set) var accountCount: String?
    
    init(accounts: [Account]) {
        setAccountCount(from: accounts)
    }
    
    private func setAccountCount(from accounts: [Account]) {
        accountCount = accounts.count == 1 ?
            "ledger-account-selection-title-singular".localized(params: accounts.count) :
            "ledger-account-selection-title-plural".localized(params: accounts.count)
    }
}
