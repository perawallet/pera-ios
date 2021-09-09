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

enum AccountImageType {
    case blush(AccountType)
    case orange(AccountType)
    case purple(AccountType)
    case turquoise(AccountType)
    case salmon(AccountType)
}

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
    private func bindImage(_ image: AccountImageType) {
        let accountImage: UIImage?

        switch image {
        case .blush(.standard):
            accountImage = img("account-blush")
        case .blush(.ledger):
            accountImage = img("ledger-blush")
        case .blush(.watch):
            accountImage = img("watch-blush")
        case .blush(.rekeyed):
            accountImage = img("rekey-blush")

        case .orange(.standard):
            accountImage = img("account-orange")
        case .orange(.ledger):
            accountImage = img("ledger-orange")
        case .orange(.watch):
            accountImage = img("watch-orange")
        case .orange(.rekeyed):
            accountImage = img("rekey-orange")

        case .purple(.standard):
            accountImage = img("account-purple")
        case .purple(.ledger):
            accountImage = img("ledger-purple")
        case .purple(.watch):
            accountImage = img("watch-purple")
        case .purple(.rekeyed):
            accountImage = img("rekey-purple")

        case .turquoise(.standard):
            accountImage = img("account-turquoise")
        case .turquoise(.ledger):
            accountImage = img("ledger-turquoise")
        case .turquoise(.watch):
            accountImage = img("watch-turquoise")
        case .turquoise(.rekeyed):
            accountImage = img("rekey-turquoise")

        case .salmon(.standard):
            accountImage = img("account-salmon")
        case .salmon(.ledger):
            accountImage = img("ledger-salmon")
        case .salmon(.watch):
            accountImage = img("watch-salmon")
        case .salmon(.rekeyed):
            accountImage = img("rekey-salmon")
        default:
            accountImage = nil
        }

        self.image = accountImage
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
