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
    let secondaryImage: UIImage?
    let assetPrimaryTitle: String?
    let assetSecondaryTitle: String?
    let assetStatus: String?
}

/// <todo> Use new list item structure
struct PendingAssetPreviewViewModel:
    ViewModel,
    Hashable {
    private(set) var id: AssetID
    private(set) var secondaryImage: UIImage?
    private(set) var assetPrimaryTitle: String?
    private(set) var assetSecondaryTitle: String?
    private(set) var assetStatus: String?

    init(update: OptInBlockchainUpdate) {
        self.id = update.assetID

        bindSecondaryImage(update: update)
        bindAssetPrimaryTitle(update: update)
        bindAssetSecondaryTitle(update: update)
        bindAssetStatus(update: update)
    }

    init(_ model: PendingAssetPreviewModel) {
        self.id = 0

        bindSecondaryImage(model.secondaryImage)
        bindAssetPrimaryTitle(model.assetPrimaryTitle)
        bindAssetSecondaryTitle(model.assetSecondaryTitle)
        bindAssetStatus(model.assetStatus)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(assetPrimaryTitle)
        hasher.combine(assetSecondaryTitle)
        hasher.combine(assetStatus)
    }

    static func == (
        lhs: PendingAssetPreviewViewModel,
        rhs: PendingAssetPreviewViewModel
    ) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.assetPrimaryTitle == rhs.assetPrimaryTitle &&
            lhs.assetSecondaryTitle == rhs.assetSecondaryTitle &&
            lhs.assetStatus == rhs.assetStatus
    }
}

extension PendingAssetPreviewViewModel {
    mutating func bindSecondaryImage(update: OptInBlockchainUpdate) {
        let icon: Image?
        switch update.assetVerificationTier {
        case .trusted: icon = "icon-trusted"
        case .verified: icon = "icon-verified"
        case .unverified: icon = nil
        case .suspicious: icon = "icon-suspicious"
        }
        self.secondaryImage = icon?.uiImage
    }

    mutating func bindAssetPrimaryTitle(update: OptInBlockchainUpdate) {
        let title = update.assetName ?? "title-unknown".localized
        self.assetPrimaryTitle = title
    }

    mutating func bindAssetSecondaryTitle(update: OptInBlockchainUpdate) {
        self.assetSecondaryTitle = update.assetUnitName
    }

    mutating func bindAssetStatus(update: OptInBlockchainUpdate) {
        self.assetStatus = "asset-add-confirmation-title".localized
    }
}

extension PendingAssetPreviewViewModel {
    private mutating func bindSecondaryImage(_ image: UIImage?) {
        self.secondaryImage = image
    }

    private mutating func bindAssetPrimaryTitle(_ title: String?) {
        self.assetPrimaryTitle = title.isNilOrEmpty ? "title-unknown".localized : title
    }

    private mutating func bindAssetSecondaryTitle(_ title: String?) {
        self.assetSecondaryTitle = title
    }

    private mutating func bindAssetStatus(_ value: String?) {
        self.assetStatus = value
    }
}
