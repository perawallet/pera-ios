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

//   WCSessionConnectionSuccessfulSheet.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCSessionConnectionSuccessfulSheet: UISheet {
    typealias EventHandler = (Event) -> Void

    private let eventHandler: EventHandler

    init(
        walletConnectSession: WalletConnectSession,
        eventHandler: @escaping EventHandler
    ) {
        self.eventHandler = eventHandler

        let title = Self.makeTitle(walletConnectSession)
        let body = Self.makeBody(walletConnectSession)
        let info = Self.makeInfo(walletConnectSession)

        super.init(
            image: "icon-approval-check",
            title: title,
            body: body,
            info: info
        )

        let closeAction = makeCloseAction()
        addAction(closeAction)
    }
}

extension WCSessionConnectionSuccessfulSheet {
    private static func makeTitle(_ walletConnectSession: WalletConnectSession) -> TextProvider {
        return Self.makeTitleForWCv2(walletConnectSession) /// <todo> For mocking purposes
    }

    private static func makeBody(_ walletConnectSession: WalletConnectSession) -> UISheetBodyTextProvider {
        return Self.makeBodyForWCv2(walletConnectSession) /// <todo> For mocking purposes
    }

    private static func makeInfo(_ walletConnectSession: WalletConnectSession) -> TextProvider? {
        return makeInfoForWCv2(walletConnectSession) /// <todo> For mocking purposes
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

extension WCSessionConnectionSuccessfulSheet {
    private static func makeTitleForWCv1(_ walletConnectSession: WalletConnectSession) -> TextProvider {
        let dAppName = walletConnectSession.dAppInfo.peerMeta.name
        let aTitle =
            "wallet-connect-session-connection-approved-title"
                .localized(dAppName)
                .bodyLargeMedium(alignment: .center)
        return aTitle
    }

    private static func makeTitleForWCv2(_ walletConnectSession: WalletConnectSession) -> TextProvider {
        let dAppName = walletConnectSession.dAppInfo.peerMeta.name
        let aTitle =
            "wallet-connect-session-connection-approved-title"
                .localized(dAppName)
                .bodyLargeMedium(alignment: .center)
        return aTitle
    }
}

extension WCSessionConnectionSuccessfulSheet {
    private static func makeBodyForWCv1(_ walletConnectSession: WalletConnectSession) -> UISheetBodyTextProvider {
        let dAppName = walletConnectSession.dAppInfo.peerMeta.name
        let aBody = "wallet-connect-session-connection-approved-description"
            .localized(dAppName)
            .bodyRegular(alignment: .center)
        return UISheetBodyTextProvider(text: aBody)
    }

    private static func makeBodyForWCv2(_ walletConnectSession: WalletConnectSession) -> UISheetBodyTextProvider {
        var textAttributes = Typography.bodyRegularAttributes(alignment: .center)
        textAttributes.insert(.textColor(Colors.Text.gray))

        let validUntilDate = "Apr 15,2023, 2:20 PM"
        let text =
            "wallet-connect-v2-session-valid-until-date"
                .localized(params: validUntilDate)
                .attributed(textAttributes)

        var validUntilDateAttributes = Typography.bodyMediumAttributes(alignment: .center)
        validUntilDateAttributes.insert(.textColor(Colors.Text.main))

        let aBody =
            text
                .addAttributes(
                    to: validUntilDate,
                    newAttributes: validUntilDateAttributes
                )
        return UISheetBodyTextProvider(text: aBody)
    }
}

extension WCSessionConnectionSuccessfulSheet {
    private static func makeInfoForWCv2(_ walletConnectSession: WalletConnectSession) -> TextProvider {
        let extendedDate = "May 8, 2023"
        let dAppName = walletConnectSession.dAppInfo.peerMeta.name

        var textAttributes = Typography.footnoteRegularAttributes(alignment: .left)
        textAttributes.insert(.textColor(Colors.Text.gray))
        let text =
            "wallet-connect-v2-session-connection-approved-description"
                .localized(params: extendedDate, dAppName)
                .attributed(textAttributes)

        let extendedDateAttributes = Typography.footnoteMediumAttributes(alignment: .left)
        let aInfo = text.addAttributes(
            to: extendedDate,
            newAttributes: extendedDateAttributes
        )
        return aInfo
    }
}

extension WCSessionConnectionSuccessfulSheet {
    enum Event {
        case didClose
    }
}
