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
//   WCSingleTransactionRequestMiddleViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCSingleTransactionRequestMiddleViewModel {
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var isAssetIconHidden: Bool = true

    var assetDetail: AssetDetail? {
        didSet {
            self.setData(transaction, for: account)
        }
    }

    private let transaction: WCTransaction
    private let account: Account?

    init(transaction: WCTransaction, account: Account?) {
        self.transaction = transaction
        self.account = account
        
        self.setData(transaction, for: account)
    }

    private func setData(_ transaction: WCTransaction, for account: Account?) {
        guard let type = transaction.transactionDetail?.transactionType(for: account) else {
            return
        }

        switch type {
        case .algos:
            self.title = "\(transaction.transactionDetail?.amount.toAlgos.toAlgosStringForLabel ?? "") ALGO"
            self.isAssetIconHidden = true
        case .asset:
            guard let assetDetail = assetDetail else {
                return
            }

            let decimals = assetDetail.fractionDecimals

            let amount = transaction.transactionDetail?.amount.assetAmount(fromFraction: decimals).toFractionStringForLabel(fraction: decimals) ?? ""

            let assetCode = assetDetail.hasOnlyAssetName() ? assetDetail.getAssetName() : assetDetail.getAssetCode()
            self.title = "\(amount) \(assetCode)"
            
            self.isAssetIconHidden = !assetDetail.isVerified
        case .assetAddition, .possibleAssetAddition:
            guard let assetDetail = assetDetail else {
                return
            }
            self.title = assetDetail.getAssetName()
            self.subtitle = "\(assetDetail.id)"
            self.isAssetIconHidden = !assetDetail.isVerified
            return
        case .appCall:
            let appCallOncomplete = transaction.transactionDetail?.appCallOnComplete ?? .noOp

            switch appCallOncomplete {
            case .delete:
                break
            case .update:
                break
            default:
                if (transaction.transactionDetail?.isAppCreateTransaction ?? false) {
                    self.title = "single-transaction-request-opt-in-title".localized
                    self.subtitle = "single-transaction-request-opt-in-subtitle".localized
                    self.isAssetIconHidden = true
                    return
                }
            }
            
            guard let id = transaction.transactionDetail?.appCallId else {
                return
            }

            self.title = "#\(id)"
            self.subtitle = "wallet-connect-transaction-title-app-id".localized
            self.isAssetIconHidden = true
        case .assetConfig(let type):
            switch type {
            case .create:
                if let assetConfigParams = transaction.transactionDetail?.assetConfigParams {
                    self.title = "\(assetConfigParams.name ?? assetConfigParams.unitName ?? "title-unknown".localized)"

                    self.isAssetIconHidden = assetConfigParams.name.isNilOrEmpty && assetConfigParams.unitName.isNilOrEmpty
                }
            case .reconfig:
                if let assetDetail = assetDetail {
                    self.title = "\(assetDetail.assetName ?? assetDetail.unitName ?? "title-unknown".localized)"
                    self.subtitle = "#\(assetDetail.id)"
                    self.isAssetIconHidden = !assetDetail.isVerified
                }
            case .delete:
                if let assetDetail = assetDetail {
                    self.title = "\(assetDetail.assetName ?? assetDetail.unitName ?? "title-unknown".localized)"
                    self.subtitle = "#\(assetDetail.id)"
                    self.isAssetIconHidden = !assetDetail.isVerified
                }
            }
        }

    }
}
