//
//  AccountTypeViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AccountTypeViewModel {
    
    private(set) var typeImage: UIImage?
    private(set) var title: String?
    private(set) var isNew: Bool = false
    private(set) var detail: String?
    
    init(accountSetupMode: AccountSetupMode) {
        setTypeImage(for: accountSetupMode)
        setTitle(for: accountSetupMode)
        setNewTitle(for: accountSetupMode)
        setDetail(for: accountSetupMode)
    }
    
    private func setTypeImage(for accountSetupMode: AccountSetupMode) {
        switch accountSetupMode {
        case .create:
            typeImage = img("icon-introduction-create")
        case .watch:
            typeImage = img("icon-introduction-watch")
        case .recover:
            typeImage = img("icon-introduction-recover")
        case .pair:
            typeImage = img("icon-introduction-ledger")
        default:
            break
        }
    }
    
    private func setTitle(for accountSetupMode: AccountSetupMode) {
        switch accountSetupMode {
        case .create:
            title = "account-type-selection-create".localized
        case .watch:
            title = "title-watch-account".localized
        case .recover:
            title = "introduction-recover-title".localized
        case .pair:
            title = "ledger-device-list-title".localized
        default:
            break
        }
    }
    
    private func setNewTitle(for accountSetupMode: AccountSetupMode) {
        switch accountSetupMode {
        case .watch:
            isNew = true
        default:
            isNew = false
        }
    }
    
    private func setDetail(for accountSetupMode: AccountSetupMode) {
        switch accountSetupMode {
        case .create:
            detail = "account-type-selection-create-detail".localized
        case .watch:
            detail = "account-type-selection-watch-detail".localized
        case .recover:
            detail = "account-type-selection-create-detail".localized
        case .pair:
            detail = "account-type-selection-create-detail".localized
        default:
            break
        }
    }
}
