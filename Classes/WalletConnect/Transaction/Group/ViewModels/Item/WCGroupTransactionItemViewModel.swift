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
//   WCGroupTransactionItemViewModel.swift

import UIKit

class WCGroupTransactionItemViewModel {
    private(set) var hasWarning = false
    private(set) var title: String?
    private(set) var isAlgos = true
    private(set) var amount: String?
    private(set) var assetName: String?
    private(set) var accountInformationViewModel: WCGroupTransactionAccountInformationViewModel?

    init(transaction: WCTransaction, account: Account?, assetInformation: AssetInformation?) {
        setHasWarning(from: transaction)
        setTitle(from: transaction, and: account)
        setIsAlgos(from: transaction)
        setAmount(from: transaction, and: assetInformation)
        setAssetName(from: assetInformation)
        setAccountInformationViewModel(from: account, with: assetInformation)
    }

    private func setHasWarning(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        hasWarning = transactionDetail.hasRekeyOrCloseAddress
    }

    private func setTitle(from transaction: WCTransaction, and account: Account?) {
        guard let transactionDetail = transaction.transactionDetail,
              let transactionType = transactionDetail.transactionType(for: account) else {
            return
        }

        switch transactionType {
        case .algos:
            return
        case .asset:
            return
        case .assetAddition:
            if let assetId = transactionDetail.assetId {
                title = "wallet-connect-transaction-group-asset-addition-title".localized(params: "\(assetId)")
            }
        case .possibleAssetAddition:
            if let assetId = transactionDetail.assetId {
                title = "wallet-connect-transaction-group-possible-asset-addition-title".localized(params: "\(assetId)")
            }
        case .appCall:
            guard let appCallId = transactionDetail.appCallId else {
                return
            }

            if transactionDetail.isAppCreateTransaction {
                title = "wallet-connect-transaction-title-app-creation".localized
                return
            }

            guard let appCallOnComplete = transactionDetail.appCallOnComplete else {
                title = "wallet-connect-transaction-group-app-call-title".localized(params: "\(appCallId)")
                return
            }

            switch appCallOnComplete {
            case .close:
                title = "wallet-connect-transaction-group-app-close-title".localized(params: "\(appCallId)")
            case .optIn:
                title = "wallet-connect-transaction-group-app-opt-in-title".localized(params: "\(appCallId)")
            case .update:
                title = "wallet-connect-transaction-group-app-update-title".localized(params: "\(appCallId)")
            case .delete:
                title = "wallet-connect-transaction-group-app-delete-title".localized(params: "\(appCallId)")
            default:
                title = "wallet-connect-transaction-group-app-call-title".localized(params: "\(appCallId)")
            }
        case .assetConfig:
            break
        }
    }

    private func setIsAlgos(from transaction: WCTransaction) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }

        isAlgos = transactionDetail.isAlgosTransaction
    }

    private func setAmount(from transaction: WCTransaction, and assetInformation: AssetInformation?) {
        guard let transactionDetail = transaction.transactionDetail else {
            return
        }
        
        if let assetInformation = assetInformation {
            let decimals = assetInformation.decimals
            amount = transactionDetail.amount.assetAmount(fromFraction: decimals).toFractionStringForLabel(fraction: decimals) ?? ""
        } else {
            amount = transactionDetail.amount.toAlgos.toAlgosStringForLabel ?? ""
        }
    }

    private func setAssetName(from assetInformation: AssetInformation?) {
        guard let assetInformation = assetInformation else {
            assetName = "ALGO"
            return
        }

        assetName = assetInformation.getDisplayNames().1
    }

    private func setAccountInformationViewModel(from account: Account?, with assetInformation: AssetInformation?) {
        guard let account = account else {
            return
        }

        accountInformationViewModel = WCGroupTransactionAccountInformationViewModel(
            account: account,
            assetInformation: assetInformation,
            isDisplayingAmount: true
        )
    }
}

extension WCGroupTransactionItemViewModel {
    static func calculatePreferredSize(_ viewModel: WCGroupTransactionItemViewModel, fittingIn size: CGSize) -> CGSize {

        var currentSize = size
        var defaultHeight: CGFloat = 65

        currentSize.width -= 45 // 45 is for main insets

        if viewModel.accountInformationViewModel != nil {
            defaultHeight += 36 + 8 // 36 is for account view, 8 is for top inset
        }

        guard viewModel.title == nil else {
            guard let title = viewModel.title else {
                return size
            }

            let totalSize = title.boundingSize(
                attributes: .font(Fonts.DMMono.regular.make(19).uiFont),
                multiline: true,
                fittingSize: currentSize
            )

            return CGSize(width: size.width, height: totalSize.height + defaultHeight)
        }

        guard let amount = viewModel.amount else {
            return size
        }

        if viewModel.hasWarning {
            currentSize.width -= 24 + 4 // 24 is for warning icon size, 4 is for spacing
        }

        guard let assetName = viewModel.assetName else {
            let amountSize = viewModel.amount?.boundingSize(
                attributes: .font(Fonts.DMMono.regular.make(19).uiFont),
                multiline: true,
                fittingSize: currentSize
            )

            let fittingSize = amountSize ?? size
            return CGSize(width: size.width, height: fittingSize.height + defaultHeight)
        }

        currentSize.width -= 4 // 4 is for spacing if asset name

        let totalSize = amount.appending(assetName).boundingSize(
            attributes: .font(Fonts.DMMono.regular.make(19).uiFont),
            multiline: true,
            fittingSize: currentSize
        )

        return CGSize(width: size.width, height: totalSize.height + defaultHeight)
    }
}
