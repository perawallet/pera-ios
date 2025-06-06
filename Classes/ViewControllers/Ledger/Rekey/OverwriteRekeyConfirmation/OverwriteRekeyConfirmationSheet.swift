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

//   OverwriteRekeyConfirmationSheet.swift

import Foundation
import MacaroonUIKit

final class OverwriteRekeyConfirmationSheet: UISheet {
    typealias EventHandler = (Event) -> Void

    private let eventHandler: EventHandler

    init(
        sourceAccount: Account,
        authAccount: Account,
        eventHandler: @escaping EventHandler
    ) {
        self.eventHandler = eventHandler

        let title =
            String(localized: "title-overwrite-rekey-confirmation")
                .bodyLargeMedium(alignment: .center)
        let body = Self.makeBody(
            sourceAccount: sourceAccount,
            authAccount: authAccount
        )

        super.init(image: "icon-info-red", title: title, body: body)

        self.bodyHyperlinkHandler = {
            [unowned self] in
            self.eventHandler(.didTapLearnMore)
        }

        let confirmAction = makeConfirmAction()
        addAction(confirmAction)

        let cancelAction = makeCancelAction()
        addAction(cancelAction)
    }
}

extension OverwriteRekeyConfirmationSheet {
    private static func makeBody(
        sourceAccount: Account,
        authAccount: Account
    ) -> UISheetBodyTextProvider {
        let sourceAccountName = sourceAccount.primaryDisplayName
        let authAccountName =  authAccount.primaryDisplayName
        let text = String(format: String(localized: "overwrite-undo-rekey-confirmation-body"), authAccountName, sourceAccountName)
        let attributedBody = NSMutableAttributedString(
            attributedString: text.bodyRegular(alignment: .center)
        )

        let highlightedTexts = [
            sourceAccountName,
            authAccountName
        ]
        var highlightedTextAttributes = Typography.bodyMediumAttributes(alignment: .center)
        highlightedTextAttributes.insert(.textColor(Colors.Text.gray))

        let body = attributedBody.string as NSString

        highlightedTexts.forEach { text in
            let range = body.range(of: text)

            attributedBody.addAttributes(
                highlightedTextAttributes.asSystemAttributes(),
                range: range
            )
        }

        let bodyHighlightedText = String(localized: "title-learn-more")

        var bodyHighlightedTextAttributes = Typography.bodyMediumAttributes(alignment: .center)
        bodyHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        let uiSheetBodyHighlightedText = UISheet.HighlightedText(
            text: bodyHighlightedText,
            attributes: bodyHighlightedTextAttributes
        )
        let uiSheetBody = UISheetBodyTextProvider(
            text: attributedBody,
            highlightedText: uiSheetBodyHighlightedText
        )

        return uiSheetBody
    }

    private func makeConfirmAction() -> UISheetAction {
        return UISheetAction(
            title: String(localized: "title-confirm"),
            style: .default
        ) {
            [unowned self] in
            self.eventHandler(.didConfirm)
        }
    }

    private func makeCancelAction() -> UISheetAction {
        return UISheetAction(
            title: String(localized: "title-cancel"),
            style: .cancel
        ) {
            [unowned self] in
            self.eventHandler(.didCancel)
        }
    }
}

extension OverwriteRekeyConfirmationSheet {
    enum Event {
        case didConfirm
        case didCancel
        case didTapLearnMore
    }
}
