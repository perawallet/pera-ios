//
//  AccountNameViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AccountNameViewModel {
    
    private(set) var image: UIImage?
    private(set) var name: String?
    
    init(account: Account) {
        setImage(from: account)
        setName(from: account)
    }
    
    private func setImage(from account: Account) {
        image = account.accountImage()
    }
    
    private func setName(from account: Account) {
        name = account.name.unwrap(or: account.address.shortAddressDisplay())
    }
}
