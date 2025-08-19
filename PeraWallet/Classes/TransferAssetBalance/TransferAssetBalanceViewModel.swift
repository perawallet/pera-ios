// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   TransferAssetBalanceViewModel.swift

import Foundation
import MacaroonUIKit

struct TransferAssetBalanceViewModel: ViewModel {
    var title: String?
    var assetID: SecondaryListItemViewModel?
    var account: SecondaryListItemViewModel?
    var description: TextProvider?
    var approveAction: TextProvider?
    var closeAction: TextProvider?

    init(
        draft: TransferAssetBalanceDraft
    ) {
        bindTitle(draft)
        bindAssetID(draft)
        bindAccount(draft)
        bindDescription(draft)
        bindApproveAction()
        bindCloseAction()
    }
}

extension TransferAssetBalanceViewModel {
    private mutating func bindTitle(
        _ draft: TransferAssetBalanceDraft
    ) {
        let asset = draft.asset

        if draft.isTransferingCollectibleAssetBalance {
            title = String(format: String(localized: "collectible-detail-opt-out-alert-title"), asset.naming.unitName ?? String(localized: "title-unknown"))
        } else {
            title = String(localized: "asset-remove-confirmation-title")
        }
    }

    private mutating func bindAssetID(
        _ draft: TransferAssetBalanceDraft
    ) {
        assetID = AssetIDSecondaryListItemViewModel(
            assetID: draft.asset.id
        )
    }

    private mutating func bindAccount(
        _ draft: TransferAssetBalanceDraft
    ) {
        account = AccountSecondaryListItemViewModel(
            account: draft.account
        )
    }

    private mutating func bindDescription(
        _ draft: TransferAssetBalanceDraft
    ) {
        let asset = draft.asset

        let assetName = asset.naming.unitName ?? String(localized: "title-unknown")
        let accountName = draft.account.primaryDisplayName
        
        let aDescription = String(format: String(localized: "asset-remove-warning"), assetName, accountName)

        description = aDescription.bodyRegular()
    }

    private mutating func bindApproveAction() {
        approveAction = String(localized: "asset-transfer-balance")
    }

    private mutating func bindCloseAction() {
        closeAction = String(localized: "title-keep")
    }
}
