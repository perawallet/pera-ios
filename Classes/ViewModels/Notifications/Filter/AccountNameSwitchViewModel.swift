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

    init(account: Account) {
        accountNameViewModel = AccountNameViewModel(account: account)
        setIsSelected()
    }

    private func setIsSelected() {

    }
}
