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

//   AssetNameViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetNameViewModel:
    PrimaryTitleViewModel,
    Hashable {
    var title: EditText?
    var icon: Image?
    var subtitle: EditText?

    init(
        _ asset: Asset?
    ) {
        if let asset = asset {
            bindTitle(asset)
            bindIcon(asset)
            bindSubtitle(asset)
            return
        }

        bindAlgoTitle()
        bindAlgoIcon()
        bindAlgoSubtitle()
    }
}

extension AssetNameViewModel {
    private mutating func bindAlgoTitle() {
        title = .attributedString("Algo".bodyRegular())
    }

    private mutating func bindAlgoIcon() {
        icon = "icon-trusted"
    }

    private mutating func bindAlgoSubtitle() {
        subtitle = .attributedString("ALGO".footnoteRegular())
    }
}

extension AssetNameViewModel {
    private mutating func bindTitle(
        _ asset: Asset
    ) {
        let name = asset.presentation.name
        let aTitle = name.isNilOrEmpty
            ? "title-unknown".localized
            : name

        guard let aTitle = aTitle else {
            return
        }

        title = .attributedString(aTitle.bodyRegular())
    }

    private mutating func bindIcon(
        _ asset: Asset
    ) {
        switch asset.presentation.verificationTier {
        case .trusted:
            icon = "icon-trusted"
        case .verified:
            icon = "icon-verified"
        case .unverified:
            break
        case .suspicious:
            icon = "icon-suspicious"
        }
    }

    private mutating func bindSubtitle(
        _ asset: Asset
    ) {
        guard let unitName = asset.presentation.unitName else {
            return
        }

        subtitle = .attributedString(unitName.footnoteRegular())
    }
}
