// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WelcomeTypeViewModel.swift

import UIKit
import MacaroonUIKit
import Foundation

struct WelcomeTypeViewModel: PairedViewModel {
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

extension WelcomeTypeViewModel {
    private mutating func bindImage(_ mode: AccountSetupMode) {
        switch mode {
        case .addBip39Wallet:
            image = img("icon-options-create-wallet")
        case .recover:
            image = img("icon-options-view-passphrase")
        case .addAlgo25Account,
             .addBip39Address,
             .rekey,
             .watch,
             .none:
            break
        }
    }
    
    private mutating func bindTitle(_ mode: AccountSetupMode) {
        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.main))
        var titleText: String = ""
        
        switch mode {
        case .addBip39Wallet:
            titleText = String(localized: "account-type-selection-create-wallet")
        case .recover:
            titleText = String(localized: "account-type-selection-recover")
        case .addAlgo25Account,
             .addBip39Address,
             .rekey,
             .watch,
             .none:
            break
        }
        
        title = .attributedString(titleText.attributed(attributes))
    }

    private mutating func bindDetail(_ mode: AccountSetupMode) {
        var attributes = Typography.footnoteRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))
        var detailText: String = ""
        
        switch mode {
        case .addBip39Wallet:
            detailText = String(localized: "account-type-selection-create-wallet-detail-title")
        case .recover:
            detailText = String(localized: "account-type-selection-recover-detail-title")
        case .addAlgo25Account,
             .addBip39Address,
             .rekey,
             .watch,
             .none:
            break
        }
        
        detail = .attributedString(detailText.attributed(attributes))
    }
}
