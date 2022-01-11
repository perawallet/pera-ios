// Copyright 2019 Algorand, Inc.

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
//   UnavailableAccountOptionsViewModel.swift

import UIKit
import MacaroonUIKit

final class UnavailableAccountOptionsViewModel: ViewModel {
    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var subtitle: String?

    init(
        option: UnavailableAccountOptionsViewController.Options,
        account: Account
    ) {
        bindImage(for: option, with: account)
        bindTitle(for: option, with: account)
        bindSubtitle(for: option, with: account)
    }
}

extension UnavailableAccountOptionsViewModel {
    private func bindImage(for option: UnavailableAccountOptionsViewController.Options, with account: Account) {
        switch option {
        case .copyAddress:
            image = img("icon-copy")
        case .viewPassphrase:
            image = img("icon-options-view-passphrase")
        case .showQR:
            image = img("icon-qr")
        }
    }

    private func bindTitle(for option: UnavailableAccountOptionsViewController.Options, with account: Account) {
        switch option {
        case .copyAddress:
            title = "options-copy-address".localized
        case .viewPassphrase:
            title = "options-view-passphrase".localized
        case .showQR:
            title = "options-show-qr".localized
        }
    }

    private func bindSubtitle(for option: UnavailableAccountOptionsViewController.Options, with account: Account) {
        switch option {
        case .copyAddress:
            subtitle = account.address
        default:
            break
        }
    }
}
