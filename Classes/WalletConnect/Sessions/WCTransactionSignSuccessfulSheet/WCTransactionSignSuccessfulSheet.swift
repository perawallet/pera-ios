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

//   WCTransactionSignSuccessfulSheet.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCTransactionSignSuccessfulSheet: UISheet {
    typealias EventHandler = (Event) -> Void

    private let eventHandler: EventHandler

    init(
        wcSession: WCSession,
        eventHandler: @escaping EventHandler
    ) {
        self.eventHandler = eventHandler

        let title = Self.makeTitle()
        let body = Self.makeBody(wcSession)
        let info = Self.makeInfo(wcSession)

        super.init(
            image: "icon-info-orange",
            title: title,
            body: body,
            info: info
        )

        let closeAction = makeCloseAction()
        addAction(closeAction)
    }
}

extension WCTransactionSignSuccessfulSheet {
    private static func makeTitle() -> TextProvider {
        return Self.makeTitleForWCv2() /// <todo> For mocking purposes
    }

    private static func makeBody(_ wcSession: WCSession) -> UISheetBodyTextProvider {
        return Self.makeBodyForWCv2(wcSession) /// <todo> For mocking purposes
    }

    private static func makeInfo(_ wcSession: WCSession) -> TextProvider? {
        return makeInfoForWCv2(wcSession) /// <todo> For mocking purposes
    }

    private func makeCloseAction() -> UISheetAction {
        return UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) {
            [unowned self] in
            self.eventHandler(.didClose)
        }
    }
}

extension WCTransactionSignSuccessfulSheet {
    private static func makeTitleForWCv1() -> TextProvider {
        return
            "wc-transaction-request-signed-warning-title"
                .localized
                .bodyLargeMedium(alignment: .center)
    }

    private static func makeTitleForWCv2() -> TextProvider {
        return
            "wc-transaction-request-signed-warning-title"
                .localized
                .bodyLargeMedium(alignment: .center)
    }
}

extension WCTransactionSignSuccessfulSheet {
    private static func makeBodyForWCv1(_ wcSession: WCSession) -> UISheetBodyTextProvider {
        let dAppName = wcSession.peerMeta.name
        let aBody = "wc-transaction-request-signed-warning-message"
            .localized(dAppName, dAppName)
            .bodyRegular(alignment: .center)
        return UISheetBodyTextProvider(text: aBody)
    }

    private static func makeBodyForWCv2(_ wcSession: WCSession) -> UISheetBodyTextProvider {
        let dAppName = wcSession.peerMeta.name
        let aBody = "wc-transaction-request-signed-warning-message"
            .localized(dAppName, dAppName)
            .bodyRegular(alignment: .left)
        return UISheetBodyTextProvider(text: aBody)
    }
}

extension WCTransactionSignSuccessfulSheet {
    private static func makeInfoForWCv2(_ wcSession: WCSession) -> TextProvider {
        let maxExtendableToDate = "Apr 15, 2023, 14:20 PM"

        var textAttributes = Typography.footnoteRegularAttributes(alignment: .left)
        textAttributes.insert(.textColor(Colors.Text.gray))
        let text =
            "wc-transaction-request-signed-warning-info"
                .localized(params: maxExtendableToDate)
                .attributed(textAttributes)

        let maxExtendableToDateAttributes = Typography.footnoteMediumAttributes(alignment: .left)
        let aInfo = text.addAttributes(
            to: maxExtendableToDate,
            newAttributes: maxExtendableToDateAttributes
        )
        return aInfo
    }
}

extension WCTransactionSignSuccessfulSheet {
    enum Event {
        case didClose
    }
}
