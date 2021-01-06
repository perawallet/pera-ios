//
//  AccountNameSwitchViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

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
