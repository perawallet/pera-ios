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
    let assetName: String?
    let assetShortName: String?
    let assetValue: String?
    let secondaryAssetValue: String?
}

final class AssetPreviewViewModel: PairedViewModel {
    var image: UIImage?
    var secondaryImage: UIImage?
    var assetName: String?
    var assetShortName: String?
    var assetValue: String?
    var secondaryAssetValue: String?

    init(_ model: AssetPreviewModel) {
        bindImage(model.image)
        bindSecondaryImage(model.secondaryImage)
        bindAssetName(model.assetName)
        bindAssetShortName(model.assetShortName)
        bindAssetValue(model.assetValue)
        bindSecondaryAssetValue(model.secondaryAssetValue)
    }
}

extension AssetPreviewViewModel {
    private func bindImage(_ image: UIImage?) {
        self.image = image
    }

    private func bindSecondaryImage(_ image: UIImage?) {
        self.secondaryImage = image
    }

    private func bindAssetName(_ name: String?) {
        self.assetName = name ?? "title-unknown".localized
    }

    private func bindAssetShortName(_ name: String?) {
        self.assetShortName = name
    }

    private func bindAssetValue(_ value: String?) {
        self.assetValue = value
    }

    private func bindSecondaryAssetValue(_ value: String?) {
        self.secondaryAssetValue = value
    }
}
