//
//  AccountListViewModel.swift

import UIKit

class AccountListViewModel {
    private(set) var name: String?
    private(set) var accountImage: UIImage?
    private(set) var detail: String?
    private(set) var attributedDetail: NSAttributedString?
    private(set) var detailColor: UIColor?
    private(set) var isDisplayingImage: Bool = false

    init(account: Account, mode: AccountListViewController.Mode) {
        setName(from: account)
        setAccountImage(from: account)
        setDetail(from: account, for: mode)
        setDetailColor(from: mode)
        setIsDisplayingImage(from: mode)
    }

    private func setName(from account: Account) {
        name = account.name
    }

    private func setAccountImage(from account: Account) {
        accountImage = account.accountImage()
    }

    private func setDetail(from account: Account, for mode: AccountListViewController.Mode) {
        switch mode {
        case .assetCount:
            detail = "\(account.assetDetails.count) " + "accounts-title-assets".localized
        case let .transactionSender(assetDetail),
             let .transactionReceiver(assetDetail),
             let .contact(assetDetail):
            if let assetDetail = assetDetail {
                guard let assetAmount = account.amount(for: assetDetail)else {
                    return
                }

                let amountText = "\(assetAmount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals) ?? "")".attributed([
                    .font(UIFont.font(withWeight: .medium(size: 14.0))),
                    .textColor(Colors.Text.primary)
                ])

                let codeText = " (\(assetDetail.getAssetCode()))".attributed([
                    .font(UIFont.font(withWeight: .medium(size: 14.0))),
                    .textColor(Colors.Text.tertiary)
                ])
                attributedDetail = amountText + codeText
            } else {
                detail = account.amount.toAlgos.toAlgosStringForLabel
            }
        default:
            break
        }
    }

    private func setDetailColor(from mode: AccountListViewController.Mode) {
        switch mode {
        case let .transactionSender(assetDetail),
             let .transactionReceiver(assetDetail),
             let .contact(assetDetail):
            if assetDetail == nil {
                detailColor = Colors.Text.primary
            }
        default:
            break
        }
    }

    private func setIsDisplayingImage(from mode: AccountListViewController.Mode) {
        switch mode {
        case let .transactionSender(assetDetail),
             let .transactionReceiver(assetDetail),
             let .contact(assetDetail):
            if assetDetail == nil {
                isDisplayingImage = true
            }
        default:
            break
        }
    }
}
