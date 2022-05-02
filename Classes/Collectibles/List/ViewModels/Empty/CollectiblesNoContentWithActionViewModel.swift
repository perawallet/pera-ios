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

//   CollectiblesNoContentWithActionViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectiblesNoContentWithActionViewModel:
    NoContentWithActionViewModel,
    Hashable {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var body: EditText?
    private(set) var primaryAction: Action?
    private(set) var secondaryAction: Action?

    private let hiddenCollectibleCount: Int

    init(
        hiddenCollectibleCount: Int,
        isWatchAccount: Bool
    ) {
        self.hiddenCollectibleCount = hiddenCollectibleCount

        bindIcon()
        bindTitle()
        bindBody()

        if isWatchAccount {
            bindPrimaryActionTitle(hiddenCollectibleCount)
        } else {
            bindPrimaryActionTitle()
            bindSecondaryActionTitle(hiddenCollectibleCount)
        }
    }

    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(hiddenCollectibleCount)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.hiddenCollectibleCount == rhs.hiddenCollectibleCount
    }
}

extension CollectiblesNoContentWithActionViewModel {
    private mutating func bindIcon() {
        icon = "img-collectible-empty"
    }

    private mutating func bindTitle() {
        let font = Fonts.DMSans.medium.make(32)
        let lineHeightMultiplier = 0.96

        title = .attributedString(
            "collectibles-empty-title"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.center)
                    ])
                ])
        )
    }

    private mutating func bindBody() {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        body = .attributedString(
            "collectibles-empty-body"
                .localized
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier),
                        .textAlignment(.center)
                    ])
                ])
        )
    }
}

extension CollectiblesNoContentWithActionViewModel {
    private mutating func bindPrimaryActionTitle() {
        primaryAction = Action(
            title: .string("collectibles-receive-action".localized),
            image: "icon-plus".uiImage
        )
    }

    private mutating func bindSecondaryActionTitle(
        _ hiddenCollectibleCount: Int
    ) {
        if hiddenCollectibleCount < 1 {
            return
        }

        secondaryAction = Action(
            title: getHiddenCollectibleCountTitle(hiddenCollectibleCount),
            image: "icon-eye".uiImage
        )
    }
}

extension CollectiblesNoContentWithActionViewModel {
    private mutating func bindPrimaryActionTitle(
        _ hiddenCollectibleCount: Int
    ) {
        if hiddenCollectibleCount < 1 {
            return
        }

        primaryAction = Action(
            title: getHiddenCollectibleCountTitle(hiddenCollectibleCount),
            image: "icon-eye".uiImage
        )
    }
}

extension CollectiblesNoContentWithActionViewModel {
    private func getHiddenCollectibleCountTitle(
        _ hiddenCollectibleCount: Int
    ) -> EditText? {
        if hiddenCollectibleCount < 1 {
            return nil
        }

        return .string(
            "collectibles-empty-secondary-action-title".localized(params: "\(hiddenCollectibleCount)")
        )
    }
}
