//
//  LedgerAccountSelectionTitleViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionTitleViewModel {
    
    private let isUnselectable: Bool
    
    private var selectionImage: UIImage?
    private var accountImage: UIImage?
    private var accountName: String?
    
    init(account: Account, isUnselectable: Bool) {
        self.isUnselectable = isUnselectable
        setSelectionImage()
        setAccountImage(from: account)
        setAccountName(from: account)
    }
    
    private func setSelectionImage() {
        selectionImage = img("settings-node-inactive")
    }
    
    private func setAccountImage(from account: Account) {
        if account.isRekeyed() {
            accountImage = img("icon-account-type-rekeyed")
        } else {
            accountImage = img("img-ledger-small")
        }
    }
    
    private func setAccountName(from account: Account) {
        accountName = account.address.shortAddressDisplay()
    }
}

extension LedgerAccountSelectionTitleViewModel {
    func configure(_ view: LedgerAccountSelectionTitleView) {
        if isUnselectable {
            view.setUnselectable()
        }
        view.setSelectionImage(selectionImage)
        view.setAccountImage(accountImage)
        view.setAccountName(accountName)
    }
}
