// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CopyAddressIntroductionAlertItem.swift

import Foundation

final class CopyAddressIntroductionAlertItem:
    AlertItem,
    Storable {
    typealias Object = Any

    private(set) var storeKey: String = "copyAddressIntroduction"

    unowned let delegate: CopyAddressIntroductionAlertItemDelegate

    init(delegate: CopyAddressIntroductionAlertItemDelegate) {
        self.delegate = delegate
    }
}

extension CopyAddressIntroductionAlertItem {
    func canBeDisplayed() -> Bool {
        let resolveLegacyShouldDisplayCopyAddress = {
            let legacyCopyAddressAppOpenCountKey = "com.algorand.algorand.copy.address.count.key"
            let legacyCopyAddressAppOpenCountValue = userDefaults.integer(forKey: legacyCopyAddressAppOpenCountKey)

            return legacyCopyAddressAppOpenCountValue < 2
        }()

        if !resolveLegacyShouldDisplayCopyAddress {
            isDisplayed = true
        }

        return !isDisplayed
    }

    func makeAlert() -> Alert {
        let title = "story-copy-address-title"
            .localized
            .bodyLargeMedium(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let body = "story-copy-address-description"
            .localized
            .footnoteRegular(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let alert = Alert(
            image: "copy-address-story",
            title: title,
            body: body
        )

        let gotItAction = AlertAction(
            title: "title-got-it".localized,
            style: .secondary
        ) {
            [weak self] in
            guard let self = self else { return }
            self.delegate.copyAddressIntroductionAlertItemDidPerformGotIt(self)
        }
        alert.addAction(gotItAction)

        return alert
    }
}

protocol CopyAddressIntroductionAlertItemDelegate: AnyObject {
    func copyAddressIntroductionAlertItemDidPerformGotIt(_ item: CopyAddressIntroductionAlertItem)
}
