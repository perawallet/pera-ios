//
//  AuthAccountNameViewModel.swift

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
