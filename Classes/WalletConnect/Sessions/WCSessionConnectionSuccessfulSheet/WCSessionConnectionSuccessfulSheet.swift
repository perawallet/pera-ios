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
        draft: WCSessionDraft,
        pairExpiryDate: Date?,
        eventHandler: @escaping EventHandler
    ) {
        self.eventHandler = eventHandler

        let title = Self.makeTitle(draft)
        let body = Self.makeBody(draft)
        let info = Self.makeInfo(
            draft: draft,
            pairExpiryDate: pairExpiryDate
        )

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
    private static func makeTitle(_ draft: WCSessionDraft) -> TextProvider? {
        if let wcV1Session = draft.wcV1Session {
            return Self.makeTitleForWCv1(wcV1Session)
        }

        if let wcV2Session = draft.wcV2Session {
            return Self.makeTitleForWCv2(wcV2Session)
        }

        return nil
    }

    private static func makeBody(_ draft: WCSessionDraft) -> UISheetBodyTextProvider? {
        if let wcV1Session = draft.wcV1Session {
            return Self.makeBodyForWCv1(wcV1Session)
        }

        if let wcV2Session = draft.wcV2Session {
            return Self.makeBodyForWCv2(wcV2Session)
        }

        return nil
    }

    private static func makeInfo(
        draft: WCSessionDraft,
        pairExpiryDate: Date?
    ) -> TextProvider? {
        if draft.isWCv1Session {
            return nil
        }

        if let wcV2Session = draft.wcV2Session {
            return Self.makeInfoForWCv2(
                wcV2Session: wcV2Session
            )
        }

        return nil
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

extension WCSessionConnectionSuccessfulSheet {
    private static func makeTitleForWCv1(_ wcV1Session: WCSession) -> TextProvider {
        return String(format: String(localized: "wallet-connect-session-connection-approved-title"), wcV1Session.peerMeta.name).bodyLargeMedium(alignment: .center)
    }

    private static func makeTitleForWCv2(_ wcV2Session: WalletConnectV2Session) -> TextProvider {
        return String(format: String(localized: "wallet-connect-session-connection-approved-title"), wcV2Session.peer.name).bodyLargeMedium(alignment: .center)
    }
}

extension WCSessionConnectionSuccessfulSheet {
    private static func makeBodyForWCv1(_ wcV1Session: WCSession) -> UISheetBodyTextProvider {
        let aBody = String(format: String(localized: "wallet-connect-session-connection-approved-description"), wcV1Session.peerMeta.name).bodyRegular(alignment: .center)
        return UISheetBodyTextProvider(text: aBody)
    }

    private static func makeBodyForWCv2(_ wcV2Session: WalletConnectV2Session) -> UISheetBodyTextProvider? {
        let expiryDate = wcV2Session.expiryDate

        var textAttributes = Typography.bodyRegularAttributes(alignment: .center)
        textAttributes.insert(.textColor(Colors.Text.gray))

        let dateFormat = "MMM d, yyyy, h:mm a"
        let validUntilDate = expiryDate.toFormat(dateFormat)
        let text = String(format: String(localized: "wallet-connect-v2-session-valid-until-date"), validUntilDate).attributed(textAttributes)

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
    private static func makeInfoForWCv2(
        wcV2Session: WalletConnectV2Session
    ) -> TextProvider? {
        var textAttributes = Typography.footnoteRegularAttributes(alignment: .left)
        textAttributes.insert(.textColor(Colors.Text.gray))
        return String(format: String(localized: "wallet-connect-v2-session-connection-approved-description"), wcV2Session.peer.name).attributed(textAttributes)
    }
}

extension WCSessionConnectionSuccessfulSheet {
    enum Event {
        case didClose
    }
}
