// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AccountTypeViewModel.swift

import UIKit
import MacaroonUIKit
import Foundation
import pera_wallet_core

struct AccountTypeViewModel: PairedViewModel {
    private(set) var image: UIImage?
    private(set) var title: EditText?
    private(set) var detail: EditText?
    private(set) var badge: String?
    private(set) var shouldShowNewAccountWarning = false
    
    init(_ model: AccountSetupMode) {
        bindImage(model)
        bindTitle(model)
        bindDetail(model)
        
        shouldShowNewAccountWarning = model.shouldShowNewAccountWarning
    }
}

extension AccountTypeViewModel {
    private mutating func bindImage(_ mode: AccountSetupMode) {
        switch mode {
        case .addAlgo25Account, .addBip39Wallet:
            image = img("icon-add-account")
        case .addBip39Address:
            image = img("icon-add-address")
        case let .recover(type):
            switch type {
            case .titleAlgo25, .title, .passphrase, .passphraseAlgo25:
                image = img("icon-recover-passphrase")
            case .importFromSecureBackup:
                image = img("icon-import-from-secure-backup")
            case .ledger:
                image = img("icon-pair-ledger-account")
            case .importFromWeb:
                image = img("icon-import-from-web")
            case .qr:
                image = img("icon-recover-qr")
            }
        case .watch:
            image = img("icon-add-watch-account")
        case .rekey,
             .none:
            break
        }
    }
    
    private mutating func bindTitle(_ mode: AccountSetupMode) {
        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.main))
        var titleText: String = ""
        
        switch mode {
        case .addAlgo25Account:
            titleText = String(localized: "account-type-selection-create")
        case .addBip39Wallet:
            titleText = String(localized: "account-type-selection-create-wallet")
        case .addBip39Address:
            titleText = String(localized: "account-type-selection-add-account")
        case let .recover(type):
            switch type {
            case .passphrase:
                titleText = String(localized: "account-type-selection-passphrase")
            case .passphraseAlgo25:
                titleText = String(localized: "account-type-selection-passphrase-algo25")
            case .importFromSecureBackup:
                titleText = String(localized: "account-type-selection-import-secure-backup")
            case .ledger:
                titleText = String(localized: "account-type-selection-ledger")
            case .importFromWeb:
                titleText = String(localized: "account-type-selection-import-web")
            case .qr:
                titleText = String(localized: "account-type-selection-qr")
            case .titleAlgo25:
                titleText = String(localized: "account-type-selection-recover")
            case .title:
                titleText = String(localized: "account-type-selection-import-wallet")
            }
        case .watch:
            titleText = String(localized: "account-type-selection-watch-address")
        case .rekey,
             .none:
            break
        }
        
        title = .attributedString(titleText.attributed(attributes))
    }

    private mutating func bindBadge(_ mode: AccountSetupMode) {
        switch mode {
        case let .recover(type):
            switch type {
            case .importFromWeb, .importFromSecureBackup:
                badge = String(localized: "title-new-uppercased")
            default:
                break
            }
        default:
            break
        }
    }

    private mutating func bindDetail(_ mode: AccountSetupMode) {
        var attributes = Typography.footnoteRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))
        var detailText: String = ""
        
        switch mode {
        case .addAlgo25Account:
            detailText = String(localized: "account-type-selection-add-detail")
        case .addBip39Wallet:
            detailText = String(localized: "account-type-selection-create-wallet-detail")
        case .addBip39Address:
            detailText = String(localized: "account-type-selection-create-universal-wallet-detail")
        case let .recover(type):
            switch type {
            case .passphrase:
                detailText = String(localized: "account-type-selection-passphrase-detail")
            case .passphraseAlgo25:
                detailText = String(localized: "account-type-selection-passphrase-detail-algo25")
            case .importFromSecureBackup:
                detailText = String(localized: "account-type-selection-import-secure-backup-detail")
            case .ledger:
                detailText = String(localized: "account-type-selection-ledger-detail")
            case .importFromWeb:
                detailText = String(localized: "account-type-selection-import-web-detail")
            case .qr:
                detailText = String(localized: "account-type-selection-qr-detail")
            case .titleAlgo25:
                detailText = String(localized: "account-type-selection-recover-detail")
            case .title:
                detailText = String(localized: "account-type-selection-recover-wallet-detail")
            }
        case .watch:
            detailText = String(localized: "account-type-selection-watch-detail")
        case .rekey,
             .none:
            break
        }
        
        detail = .attributedString(detailText.attributed(attributes))
    }
}
