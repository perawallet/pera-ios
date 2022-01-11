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

import MacaroonUIKit
import UIKit

struct AccountPreviewModel {
    let accountType: AccountType
    let accountImageType: AccountImageType
    let accountName: String?
    var assetsAndNFTs: String?
    var assetValue: String?
    var secondaryAssetValue: String?
    var hasError: Bool
}

final class AccountPreviewViewModel: PairedViewModel {
    private(set) var accountImageTypeImage: UIImage?
    private(set) var accountName: String?
    private(set) var assetsAndNFTs: String?
    private(set) var assetValue: String?
    private(set) var secondaryAssetValue: String?
    private(set) var hasError: Bool = false

    init(_ model: AccountPreviewModel) {
        bindAccountImageTypeImage(accountImageType: model.accountImageType, accountType: model.accountType)
        bindAccountName(model.accountName)
        bindAssetsAndNFTs(model.assetsAndNFTs)
        bindAssetValue(model.assetValue)
        bindSecondaryAssetValue(model.secondaryAssetValue)
        bindHasError(model.hasError)
    }

    convenience init(from account: Account) {
        let assetsAndNFTs: String

        if let count = account.assets?.count, count > 1 {
            assetsAndNFTs = "title-plus-asset-count".localized(params: "\(count.advanced(by: 1))")
        } else {
            assetsAndNFTs = "title-plus-asset-singular-count".localized(params: "1")
        }

        self.init(
            AccountPreviewModel(
                accountType: account.type,
                accountImageType: .orange,
                accountName: account.name,
                assetsAndNFTs: assetsAndNFTs,
                assetValue: account.amount.toAlgos.toAlgosStringForLabel,
                secondaryAssetValue: nil, /// TODO: Dollar value should be added
                hasError: false
            )
        )
    }

    convenience init(viewModel: AccountNameViewModel) {
        self.init(
            AccountPreviewModel(
                accountType: viewModel.accountType,
                accountImageType: .orange,
                accountName: viewModel .name,
                hasError: false
            )
        )
    }

    convenience init(viewModel: AuthAccountNameViewModel) {
        self.init(
            AccountPreviewModel(
                accountType: viewModel.accountType,
                accountImageType: .orange,
                accountName: viewModel.address,
                hasError: false
            )
        )
    }
}

extension AccountPreviewViewModel {
    private func bindAccountImageTypeImage(accountImageType: AccountImageType, accountType: AccountType) {
        self.accountImageTypeImage = accountType.image(for: accountImageType)
    }

    private func bindAccountName(_ name: String?) {
        self.accountName = name ?? "title-unknown".localized
    }

    private func bindAssetsAndNFTs(_ assets: String?) {
        self.assetsAndNFTs = assets
    }

    private func bindAssetValue(_ value: String?) {
        self.assetValue = value
    }

    private func bindSecondaryAssetValue(_ value: String?) {
        self.secondaryAssetValue = value
    }

    private func bindHasError(_ hasError: Bool) {
        self.hasError = hasError
    }
}
