//
//  SelectAssetViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SelectAssetViewModel {
    private(set) var accountName: String?
    private(set) var accountImage: UIImage?

    init(account: Account) {
        setAccountName(from: account)
        setAccountImage(from: account)
    }

    private func setAccountName(from account: Account) {
        accountName = account.name
    }

    private func setAccountImage(from account: Account) {
        accountImage = account.accountImage()
    }
}
