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

//
//   PendingAssetPreviewViewModel.swift

import MacaroonUIKit
import UIKit

struct PendingAssetPreviewModel: Hashable {
    let verificationTier: AssetVerificationTier
    let assetPrimaryTitle: String?
    let assetSecondaryTitle: String?
    let assetStatus: String?
}

/// <todo> Use new list item structure
struct PendingAssetPreviewViewModel:
    PairedViewModel,
    Hashable {
    private(set) var assetPrimaryTitle: String?
    private(set) var assetPrimaryTitleColor: Color?
    private(set) var secondaryImage: UIImage?
    private(set) var assetSecondaryTitle: String?
    private(set) var assetStatus: String?

    init(_ model: PendingAssetPreviewModel) {
        bindAssetPrimaryTitle(model.assetPrimaryTitle)
        bindAssetPrimaryTitleColor(model.verificationTier)
        bindSecondaryImage(model.verificationTier)
        bindAssetSecondaryTitle(model.assetSecondaryTitle)
        bindAssetStatus(model.assetStatus)
    }
}

extension PendingAssetPreviewViewModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(assetPrimaryTitle)
        hasher.combine(assetSecondaryTitle)
        hasher.combine(assetStatus)
    }

    static func == (
        lhs: PendingAssetPreviewViewModel,
        rhs: PendingAssetPreviewViewModel
    ) -> Bool {
        return
            lhs.assetPrimaryTitle == rhs.assetPrimaryTitle &&
            lhs.assetSecondaryTitle == rhs.assetSecondaryTitle &&
            lhs.assetStatus == rhs.assetStatus
    }
}

extension PendingAssetPreviewViewModel {
    private mutating func bindAssetPrimaryTitle(_ title: String?) {
        self.assetPrimaryTitle = title.isNilOrEmpty ? "title-unknown".localized : title
    }

    private mutating func bindAssetPrimaryTitleColor(_ verificationTier: AssetVerificationTier) {
        if verificationTier.isSuspicious {
            assetPrimaryTitleColor = Colors.Helpers.negative
        } else {
            assetPrimaryTitleColor = Colors.Text.main
        }
    }

    private mutating func bindSecondaryImage(_ verificationTier: AssetVerificationTier) {
        switch verificationTier {
        case .trusted: self.secondaryImage = "icon-trusted".uiImage
        case .verified: self.secondaryImage = "icon-verified".uiImage
        case .unverified: self.secondaryImage = nil
        case .suspicious: self.secondaryImage = "icon-suspicious".uiImage
        }
    }

    private mutating func bindAssetSecondaryTitle(_ title: String?) {
        self.assetSecondaryTitle = title
    }

    private mutating func bindAssetStatus(_ value: String?) {
        self.assetStatus = value
    }
}
