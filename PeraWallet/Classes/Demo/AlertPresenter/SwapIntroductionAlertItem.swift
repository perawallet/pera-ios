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

//   SwapIntroductionAlertItem.swift

import Foundation
import pera_wallet_core

final class SwapIntroductionAlertItem:
    AlertItem,
    Storable {
    typealias Object = Any

    var isAvailable: Bool { checkAvailability() }

    unowned let delegate: SwapIntroductionAlertItemDelegate

    private lazy var isSeen: Bool = userDefaults.bool(forKey: isSeenKey) {
        didSet {
            saveIsSeen()
        }
    }
    private let isSeenKey: String = "promotion.dialog.swap"

    init(delegate: SwapIntroductionAlertItemDelegate) {
        self.delegate = delegate
    }
}

extension SwapIntroductionAlertItem {
    func makeAlert() -> Alert {
        isSeen = true

        let title = String(localized: "swap-alert-title")
            .bodyLargeMedium(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let body = String(localized: "swap-alert-body")
            .footnoteRegular(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let alert = Alert(
            image: "swap-alert-illustration",
            isNewBadgeVisible: true,
            title: title,
            body: body,
            theme: AlertScreenWithFillingImageTheme()
        )

        let trySwapAction = makeTrySwapAction()
        alert.addAction(trySwapAction)

        let laterAction = makeLaterAction()
        alert.addAction(laterAction)
        return alert
    }

    func cancel() {}
}

extension SwapIntroductionAlertItem {
    private func makeTrySwapAction() -> AlertAction {
        return AlertAction(
            title: String(localized: "swap-alert-primary-action"),
            style: .primary
        ) {
            [unowned self] in
            self.delegate.swapIntroductionAlertItemDidPerformTrySwap(self)
        }
    }

    private func makeLaterAction() -> AlertAction {
        return AlertAction(
            title: String(localized: "title-later"),
            style: .secondary
        ) {
            [unowned self] in
            self.delegate.swapIntroductionAlertItemDidPerformLaterAction(self)
        }
    }
}

extension SwapIntroductionAlertItem {
    private func checkAvailability() -> Bool {
        return !isSeen
    }
}

extension SwapIntroductionAlertItem {
    private func saveIsSeen() {
        userDefaults.set(
            isSeen,
            forKey: isSeenKey
        )
    }
}

protocol SwapIntroductionAlertItemDelegate: AnyObject {
    func swapIntroductionAlertItemDidPerformTrySwap(_ item: SwapIntroductionAlertItem)
    func swapIntroductionAlertItemDidPerformLaterAction(_ item: SwapIntroductionAlertItem)
}
