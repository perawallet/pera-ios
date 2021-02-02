//
//  AccountNameSwitchViewModel.swift

import Foundation

class AccountNameSwitchViewModel {

    private(set) var accountNameViewModel: AccountNameViewModel
    private(set) var isSelected: Bool = true
    private(set) var isSeparatorHidden: Bool = false

    init(account: Account, isLastIndex: Bool) {
        accountNameViewModel = AccountNameViewModel(account: account)
        setIsSelected(from: account)
        setIsSeparatorHidden(isLastIndex: isLastIndex)
    }

    private func setIsSelected(from account: Account) {
        isSelected = account.receivesNotification
    }

    private func setIsSeparatorHidden(isLastIndex: Bool) {
        isSeparatorHidden = isLastIndex
    }
}
