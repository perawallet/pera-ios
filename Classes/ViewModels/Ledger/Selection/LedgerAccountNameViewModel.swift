//
//  LedgerAccountNameViewModel.swift

import UIKit

class LedgerAccountNameViewModel {
    
    private(set) var selectionImage: UIImage?
    private(set) var accountNameViewModel: AccountNameViewModel
    
    init(account: Account, isMultiSelect: Bool, isSelected: Bool) {
        accountNameViewModel = AccountNameViewModel(account: account)
        setSelectionImage(isMultiSelect: isMultiSelect, isSelected: isSelected)
    }
    
    private func setSelectionImage(isMultiSelect: Bool, isSelected: Bool) {
        if isMultiSelect {
            selectionImage = isSelected ? img("icon-checkbox-selected") : img("icon-checkbox-unselected")
        } else {
            selectionImage = isSelected ? img("settings-node-active") : img("settings-node-inactive")
        }
    }
}
