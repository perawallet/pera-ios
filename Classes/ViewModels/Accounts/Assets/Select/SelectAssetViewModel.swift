//
//  SelectAssetViewModel.swift

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
