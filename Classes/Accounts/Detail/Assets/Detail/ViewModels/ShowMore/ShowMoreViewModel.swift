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

//   ShowMoreViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct ShowMoreViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var detail: TextProvider?
    private(set) var showMore: TextProvider?
    private(set) var showTextOverflow: TextOverflow?

    private(set) var displayedNumberOfDetailTextLines = 0

    init(
        _ draft: ShowMoreDraft,
        width: CGFloat
    ) {
        bindTitle(draft)
        bindDetail(draft)
        bindShowMore(
            draft,
            toFitIn: width
        )
        bindShowTextOverflow(draft)
    }
}

extension ShowMoreViewModel {
    mutating func bindTitle(
        _ draft: ShowMoreDraft
    ) {
        guard let aTitle = draft.title else {
            title = nil
            return
        }

        title = aTitle.footnoteMedium()
    }

    mutating func bindDetail(
        _ draft: ShowMoreDraft
    ) {
        detail = draft.detail.bodyRegular()
    }

    mutating func bindShowMore(
        _ draft: ShowMoreDraft,
        toFitIn width: CGFloat
    ) {
        let detail = draft.detail.bodyRegular()
        let numberOfLines = detail.calculateNumberOfLines(
            toFitIn: width,
            font: Fonts.DMSans.regular.make(15, .body).uiFont
        )

        switch draft.allowedNumberOfLines {
        case .none:
            showMore = nil
        case .custom(let lineLimit):
            if lineLimit >= numberOfLines {
                displayedNumberOfDetailTextLines = numberOfLines
                showMore = nil
                return
            }

            displayedNumberOfDetailTextLines = lineLimit
            showMore = "title-show-more".localized.bodyMedium()
        case .full:
            displayedNumberOfDetailTextLines = numberOfLines
            showMore = "title-show-less".localized.bodyMedium()
        }
    }

    mutating func bindShowTextOverflow(
        _ draft: ShowMoreDraft
    ) {
        switch draft.allowedNumberOfLines {
        case .none,
            .full:
            showTextOverflow = FittingText()
        case .custom(let limit):
            showTextOverflow = MultilineText(numberOfLines: limit)
        }
    }
}
