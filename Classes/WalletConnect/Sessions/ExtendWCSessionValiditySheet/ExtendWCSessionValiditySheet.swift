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

//   ExtendWCSessionValiditySheet.swift

import Foundation
import MacaroonUIKit

final class ExtendWCSessionValiditySheet: UISheet {
    typealias EventHandler = (Event) -> Void

    private let eventHandler: EventHandler

    init(
        eventHandler: @escaping EventHandler
    ) {
        self.eventHandler = eventHandler

        let title = Self.makeTitle()
        let body = Self.makeBody()

        super.init(
            image: "img-extend-time",
            title: title,
            body: body
        )

        let confirmAction = makeConfirmAction()
        addAction(confirmAction)

        let cancelAction = makeCancelAction()
        addAction(cancelAction)
    }
}

extension ExtendWCSessionValiditySheet {
    private static func makeTitle() -> TextProvider {
        let toDate = "17.07.2023"
        let aTitle =
            "extend-wc-session-validity-title"
                .localized(params: toDate)
                .bodyLargeMedium(alignment: .center)
        return aTitle
    }

    private static func makeBody() -> UISheetBodyTextProvider {
        let maxExtendableToDate = "27.07.2023"

        let text = "extend-wc-session-validity-body".localized(params: maxExtendableToDate)

        let attributedBody = text.bodyRegular(alignment: .center)

        var highlightedTextAttributes = Typography.bodyMediumAttributes(alignment: .center)
        highlightedTextAttributes.insert(.textColor(Colors.Text.gray))

        let aBody = attributedBody.addAttributes(
            to: maxExtendableToDate,
            newAttributes: highlightedTextAttributes
        )

        return UISheetBodyTextProvider(text: aBody)
    }

    private func makeConfirmAction() -> UISheetAction {
        return UISheetAction(
            title: "title-extend".localized,
            style: .default
        ) {
            [unowned self] in
            self.eventHandler(.didConfirm)
        }
    }

    private func makeCancelAction() -> UISheetAction {
        return UISheetAction(
            title: "title-cancel".localized,
            style: .cancel
        ) {
            [unowned self] in
            self.eventHandler(.didCancel)
        }
    }
}

extension ExtendWCSessionValiditySheet {
    enum Event {
        case didConfirm
        case didCancel
    }
}
