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
//   AccountPreviewViewModel.swift

import Macaroon

struct AccountPreviewModel {
    let image: AccountImageType
    let accountName: String
    let assetsAndNFTs: String
    let assetValue: String
    let secondaryAssetValue: String
}

final class AccountPreviewViewModel: PairedViewModel {
    var image: UIImage?
    var accountName: String?
    var assetsAndNFTs: String?
    var assetValue: String?
    var secondaryAssetValue: String?

    init(_ model: AccountPreviewModel) {
        bindImage(model.image)
        bindAccountName(model.accountName)
        bindAssetsAndNFTs(model.assetsAndNFTs)
        bindAssetValue(model.assetValue)
        bindSecondaryAssetValue(model.secondaryAssetValue)
    }
}

extension AccountPreviewViewModel {
    private func bindImage(_ accountImageType: AccountImageType) {
        self.image = accountImageType.image
    }

    private func bindAccountName(_ name: String) {
        self.accountName = name
    }

    private func bindAssetsAndNFTs(_ assets: String) {
        self.assetsAndNFTs = assets
    }

    private func bindAssetValue(_ value: String) {
        self.assetValue = value
    }

    private func bindSecondaryAssetValue(_ value: String) {
        self.secondaryAssetValue = value
    }
}
