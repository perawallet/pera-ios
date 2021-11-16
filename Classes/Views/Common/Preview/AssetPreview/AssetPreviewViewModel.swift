// Copyright 2019 Algorand, Inc.

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
//   AssetPreviewViewModel.swift

import Macaroon

struct AssetPreviewModel {
    let image: UIImage?
    let secondaryImage: UIImage?
    let assetPrimaryTitle: String?
    let assetSecondaryTitle: String?
    let assetPrimaryValue: String?
    let assetSecondaryValue: String?
}

final class AssetPreviewViewModel: PairedViewModel {
    var image: UIImage?
    var secondaryImage: UIImage?
    var assetPrimaryTitle: String?
    var assetSecondaryTitle: String?
    var assetPrimaryValue: String?
    var assetSecondaryAssetValue: String?
    var assetAbbreviationForImage: String?
    
    init(_ model: AssetPreviewModel) {
        bindImage(model.image)
        bindSecondaryImage(model.secondaryImage)
        bindAssetPrimaryTitle(model.assetPrimaryTitle)
        bindAssetSecondaryTitle(model.assetSecondaryTitle)
        bindAssetPrimaryValue(model.assetPrimaryValue)
        bindAssetSecondaryValue(model.assetSecondaryValue)
        bindAssetAbbreviationForImage(model.assetPrimaryTitle)
    }
}

extension AssetPreviewViewModel {
    private func bindImage(_ image: UIImage?) {
        self.image = image
    }
    
    private func bindSecondaryImage(_ image: UIImage?) {
        self.secondaryImage = image
    }
    
    private func bindAssetPrimaryTitle(_ title: String?) {
        self.assetPrimaryTitle = title ?? "title-unknown".localized
    }
    
    private func bindAssetSecondaryTitle(_ title: String?) {
        self.assetSecondaryTitle = title
    }
    
    private func bindAssetPrimaryValue(_ value: String?) {
        self.assetPrimaryValue = value
    }
    
    private func bindAssetSecondaryValue(_ value: String?) {
        self.assetSecondaryAssetValue = value
    }

    private func bindAssetAbbreviationForImage(_ title: String?) {
        self.assetAbbreviationForImage = TextFormatter.assetShortName.format(title)
    }
}
