//
//  AccountHeaderSupplementaryViewModel.swift

import UIKit

class AccountHeaderSupplementaryViewModel {
    private(set) var accountName: String?
    private(set) var accountImage: UIImage?
    private(set) var isActionEnabled: Bool = true

    init(account: Account, isActionEnabled: Bool) {
        setAccountName(from: account)
        setAccountImage(from: account)
        setIsActionEnabled(from: isActionEnabled)
    }

    private func setAccountName(from account: Account) {
        accountName = account.name
    }

    private func setAccountImage(from account: Account) {
        accountImage = account.accountImage()
    }

    private func setIsActionEnabled(from isActionEnabled: Bool) {
        self.isActionEnabled = isActionEnabled
    }
}
