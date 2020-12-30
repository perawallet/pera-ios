//
//  AuthAccountNameViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AuthAccountNameViewModel {
    
    private(set) var image: UIImage?
    private(set) var address: String?
    
    init(account: Account) {
        setImage(from: account)
        setAddress(from: account)
    }
    
    private func setImage(from account: Account) {
        image = account.accountImage()
    }
    
    private func setAddress(from account: Account) {
        address = account.authAddress.unwrap(or: account.address).shortAddressDisplay()
    }
}
