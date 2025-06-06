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

//   WCAdvancedPermissionsInfoSheet.swift

import Foundation
import MacaroonUIKit

final class WCAdvancedPermissionsInfoSheet: UISheet {
    typealias EventHandler = (Event) -> Void

    private let eventHandler: EventHandler

    init(eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler

        let title = Self.makeTitle()
        let body = Self.makeBody()

        super.init(
            title: title,
            body: body
        )

        let closeAction = makeCloseAction()
        addAction(closeAction)
    }
}

extension WCAdvancedPermissionsInfoSheet {
    private static func makeTitle() -> TextProvider {
        return
            String(localized: "wc-advanced-permissions-info-title")
                .bodyLargeMedium()
    }

    private static func makeBody() -> UISheetBodyTextProvider {
        let aBody =
            String(localized: "wc-advanced-permissions-info-body")
                .bodyRegular()
        return UISheetBodyTextProvider(text: aBody)
    }

    private func makeCloseAction() -> UISheetAction {
        return UISheetAction(
            title: String(localized: "title-close"),
            style: .cancel
        ) {
            [unowned self] in
            self.eventHandler(.didClose)
        }
    }
}

extension WCAdvancedPermissionsInfoSheet {
    enum Event {
        case didClose
    }
}
