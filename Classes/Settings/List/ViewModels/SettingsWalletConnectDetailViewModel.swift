// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SettingsWalletConnectDetailViewModel.swift

import Foundation
import MacaroonUIKit

struct SettingsWalletConnectDetailViewModel: PrimaryTitleViewModel {
    private(set) var primaryTitle: TextProvider?
    private(set) var primaryTitleAccessory: Image?
    private(set) var secondaryTitle: TextProvider?

    init(activeSessionCount: Int) {
        bindPrimaryTitle()
        bindPrimaryTitleAccessory()
        bindSecondaryTitle(activeSessionCount)
    }
}

extension SettingsWalletConnectDetailViewModel {
    mutating func bindPrimaryTitle() {
        primaryTitle = "settings-wallet-connect-title"
            .localized
            .bodyRegular()
    }

    mutating func bindPrimaryTitleAccessory() {
        primaryTitleAccessory = nil
    }

    mutating func bindSecondaryTitle(_ activeSessionCount: Int) {
        let totalSessionLimit = WalletConnectSessionSource.sessionLimit
        let detailText = "\(activeSessionCount)/\(totalSessionLimit)"
        secondaryTitle = detailText.footnoteRegular()
    }
}
