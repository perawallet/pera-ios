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

//   CollectibleListItemViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct CollectibleListItemViewModel:
    BindableViewModel,
    Hashable {
    private(set) var image: UIImage? /// <todo> Why does ImageSource not conforming Hashable? Ask Salih for the alternative solution.
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var bottomLeftBadge: UIImage?

    init<T>(
        _ model: T
    ) {
        bind(model)
    }
}

extension CollectibleListItemViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let asset = model as? CollectibleAsset {
            bindImage(asset)
            bindTitle(asset)
            bindSubtitle(asset)
            bindBottomLeftBadge(asset)
            return
        }
    }
}

extension CollectibleListItemViewModel {
    private mutating func bindImage(
        _ asset: CollectibleAsset
    ) {
        image = nil
    }

    private mutating func bindTitle(
        _ asset: CollectibleAsset
    ) {
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18

        title = .attributedString(
            "" /// <todo>
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

    private mutating func bindSubtitle(
        _ asset: CollectibleAsset
    ) {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        subtitle = .attributedString(
            "" /// <todo>
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

    private mutating func bindBottomLeftBadge(
        _ asset: CollectibleAsset
    ) {
        bottomLeftBadge = nil
    }
}
