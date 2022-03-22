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

//   CollectibleMediaErrorViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CollectibleMediaErrorViewModel:
    ViewModel,
    Hashable {
    private(set) var image: UIImage?
    private(set) var message: EditText?

    init(
        _ error: CollectibleMediaError
    ) {
        bindImage()
        bindMessage(error)
    }
}

extension CollectibleMediaErrorViewModel {
    private mutating func bindImage() {
        image = img("badge-error")
    }

    private mutating func bindMessage(
        _ error: CollectibleMediaError
    ) {
        let font = Fonts.DMSans.medium.make(13)
        let lineHeightMultiplier = 1.18

        message = .attributedString(
            error.message.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byWordWrapping),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }
}

enum CollectibleMediaError {
    case unsupported
    case notOwner
    case unavailable

    var message: String {
        switch self {
        case .unsupported:
            return "collectible-detail-error-media-type".localized
        case .notOwner:
            return "collectible-detail-error-not-owner".localized
        case .unavailable:
            return "collectible-detail-error-visual".localized
        }
    }
}
