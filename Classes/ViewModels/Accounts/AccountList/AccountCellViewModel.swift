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
//  AccountCellViewModel.swift

import UIKit

final class AccountCellViewModel {
    private(set) var accountType: AccountType
    private(set) var name: String?
    private(set) var detail: String?
    private(set) var attributedDetail: NSAttributedString?

    init(account: Account, mode: AccountListViewController.Mode) {
        self.accountType = account.type
        bindName(account)
        bindDetail(account, for: mode)
    }
}

extension AccountCellViewModel {
    private func bindName(_ account: Account) {
        name = account.name
    }

    private func bindDetail(_ account: Account, for mode: AccountListViewController.Mode) {
        switch mode {
        case .walletConnect:
            detail = account.amount.toAlgos.toAlgosStringForLabel
        case let .transactionSender(assetDetail),
            let .transactionReceiver(assetDetail),
            let .contact(assetDetail):
            if let assetDetail = assetDetail {
                guard let assetAmount = account.amount(for: assetDetail) else {
                    return
                }

                let amountText = "\(assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals) ?? "")".attributed(
                    [
                        .textColor(AppColors.Components.Text.main.color),
                        .font(Fonts.DMMono.regular.make(15).font)
                    ]
                )

                let codeText = " (\(assetDetail.getAssetCode()))".attributed(
                    [
                        .textColor(AppColors.Components.Text.grayLighter.color),
                        .font(Fonts.DMSans.regular.make(13).font)
                    ]
                )
                attributedDetail = amountText + codeText
            } else {
                detail = account.amount.toAlgos.toAlgosStringForLabel
            }
        }
    }
}
