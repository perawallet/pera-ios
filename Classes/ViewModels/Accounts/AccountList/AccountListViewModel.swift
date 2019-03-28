//
//  AccountListViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountListViewModel {
    
    func configure(_ cell: AccountViewCell, with account: Account) {
        cell.contextView.nameLabel.text = account.name
        cell.contextView.amountLabel.text = "\(account.amount)"
    }
    
    func configure(_ cell: AccountsTotalDisplayCell, with totalAmount: String) {
        cell.contextView.amountLabel.text = totalAmount
    }
}
