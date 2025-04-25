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

struct AccountTypeViewModel: PairedViewModel {
    private(set) var image: UIImage?
    private(set) var title: EditText?
    private(set) var detail: EditText?
    private(set) var badge: String?
    
    init(_ model: AccountSetupMode) {
        bindImage(model)
        bindTitle(model)
        bindDetail(model)
    }
}

extension AccountTypeViewModel {
    private mutating func bindImage(_ mode: AccountSetupMode) {
        switch mode {
        case .add:
            image = img("icon-add-account")
        case let .recover(type):
            switch type {
            case .none, .passphrase:
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
        case .add:
            titleText = String(localized: "account-type-selection-create")
        case let .recover(type):
            switch type {
            case .passphrase:
                titleText = String(localized: "account-type-selection-passphrase")
            case .importFromSecureBackup:
                titleText = String(localized: "account-type-selection-import-secure-backup")
            case .ledger:
                titleText = String(localized: "account-type-selection-ledger")
            case .importFromWeb:
                titleText = String(localized: "account-type-selection-import-web")
            case .qr:
                titleText = String(localized: "account-type-selection-qr")
            case .none:
                titleText = String(localized: "account-type-selection-recover")
            }
        case .watch:
            titleText = String(localized: "account-type-selection-watch")
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
        case .add:
            detailText = String(localized: "account-type-selection-add-detail")
        case let .recover(type):
            switch type {
            case .passphrase:
                detailText = String(localized: "account-type-selection-passphrase-detail")
            case .importFromSecureBackup:
                detailText = String(localized: "account-type-selection-import-secure-backup-detail")
            case .ledger:
                detailText = String(localized: "account-type-selection-ledger-detail")
            case .importFromWeb:
                detailText = String(localized: "account-type-selection-import-web-detail")
            case .qr:
                detailText = String(localized: "account-type-selection-qr-detail")
            case .none:
                detailText = String(localized: "account-type-selection-recover-detail")
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
