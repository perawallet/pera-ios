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
//   TransactionHistoryContextViewModel.swift

import MacaroonUIKit
import UIKit

struct TransactionHistoryContextViewModel:
    ViewModel,
    Hashable {
    private(set) var id: String?
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var transactionAmountViewModel: TransactionAmountViewModel?

    init(rewardViewModel: RewardViewModel) {
        title = "reward-list-title".localized
        if let mode = rewardViewModel.amountMode {
            transactionAmountViewModel = TransactionAmountViewModel(mode)
        }
    }

    init(transactionDependencies: TransactionViewModelDependencies) {
        guard let transaction = transactionDependencies.transaction as? Transaction else {
            return
        }

        id = transaction.id

        let account = transactionDependencies.account
        let contact = transactionDependencies.contact

        if let assetTransaction = transaction.assetTransfer,
           let assetId = transaction.assetTransfer?.assetId,
           let assetDetail = account[assetId]?.detail {

            if assetTransaction.receiverAddress == assetTransaction.senderAddress {
                bindTitleAndSubtitle(with: contact, and: .send(assetTransaction.receiverAddress))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .normal(
                        amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                        isAlgos: false,
                        fraction: assetDetail.decimals,
                        assetSymbol: assetDetail.unitName ?? assetDetail.name
                    )
                )
            } else if transaction.isAssetAdditionTransaction(for: account.address) {
                title = "asset-creation-fee-title".localized
                if let fee = transaction.fee {
                    transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: fee.toAlgos))
                }
            } else if assetTransaction.receiverAddress == account.address {
                bindTitleAndSubtitle(with: contact, and: .receive(assetTransaction.receiverAddress))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .positive(
                        amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                        isAlgos: false,
                        fraction: assetDetail.decimals,
                        assetSymbol: assetDetail.unitName ?? assetDetail.name
                    )
                )
            } else {
                bindTitleAndSubtitle(with: contact, and: .send(assetTransaction.receiverAddress))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .negative(
                        amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                        isAlgos: false,
                        fraction: assetDetail.decimals,
                        assetSymbol: assetDetail.unitName ?? assetDetail.name
                    )
                )
            }
        } else {
            guard let payment = transaction.payment else {
                if transaction.isAssetAdditionTransaction(for: account.address) {
                    title = "asset-creation-fee-title".localized
                    if let fee = transaction.fee {
                        transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: fee.toAlgos))
                    }
                }
                return
            }

            if payment.receiver == transaction.sender {
                bindTitleAndSubtitle(with: contact, and: .receive(transaction.sender))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .normal(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
                )
            } else if payment.receiver == account.address {
                bindTitleAndSubtitle(with: contact, and: .receive(transaction.sender))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .positive(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
                )
            } else {
                bindTitleAndSubtitle(with: contact, and: .send(payment.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .negative(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
                )
            }
        }
    }

    init(pendingTransactionDependencies: TransactionViewModelDependencies) {
        guard let transaction = pendingTransactionDependencies.transaction as? PendingTransaction else {
            return
        }

        let account = pendingTransactionDependencies.account
        let contact = pendingTransactionDependencies.contact

        if let assetDetail = pendingTransactionDependencies.assetDetail {
            if transaction.receiver == transaction.sender {
                bindTitleAndSubtitle(with: contact, and: .send(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .normal(
                        amount: transaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                        isAlgos: false,
                        fraction: assetDetail.decimals,
                        assetSymbol: assetDetail.unitName ?? assetDetail.name
                    )
                )
            } else if transaction.receiver == account.address && transaction.amount == 0 && transaction.type == .assetTransfer {
                title = "asset-creation-fee-title".localized
                if let fee = transaction.fee {
                    transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: fee.toAlgos))
                }
            } else if transaction.receiver == account.address {
                bindTitleAndSubtitle(with: contact, and: .send(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .positive(
                        amount: transaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                        isAlgos: false,
                        fraction: assetDetail.decimals,
                        assetSymbol: assetDetail.unitName ?? assetDetail.name
                    )
                )
            } else {
                bindTitleAndSubtitle(with: contact, and: .send(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .negative(
                        amount: transaction.amount.assetAmount(fromFraction: assetDetail.decimals),
                        isAlgos: false,
                        fraction: assetDetail.decimals,
                        assetSymbol: assetDetail.unitName ?? assetDetail.name
                    )
                )
            }
        } else {
            if transaction.receiver == transaction.sender {
                bindTitleAndSubtitle(with: contact, and: .send(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(.normal(amount: transaction.amount.toAlgos))
            } else if transaction.receiver == account.address {
                bindTitleAndSubtitle(with: contact, and: .receive(transaction.sender))
                transactionAmountViewModel = TransactionAmountViewModel(.positive(amount: transaction.amount.toAlgos))
            } else {
                bindTitleAndSubtitle(with: contact, and: .send(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: transaction.amount.toAlgos))
            }
        }
    }
}

extension TransactionHistoryContextViewModel {
    private mutating func bindTitleAndSubtitle(with contact: Contact?, and address: Address?) {
        title = address?.title

        if let contact = contact {
            subtitle = contact.name
        } else if let address = address?.associatedValue,
                  let localAccount = UIApplication.shared.appConfiguration?.session.accountInformation(
                    from: address
                  ) {
            subtitle = localAccount.name
        } else {
            subtitle = address?.associatedValue.shortAddressDisplay()
        }
    }

    private enum Address {
        case send(String?)
        case receive(String?)

        var title: String {
            switch self {
            case .send:
                return "transaction-detail-send".localized
            case .receive:
                return "transaction-detail-receive".localized
            }
        }

        var associatedValue: String? {
            switch self {
            case let .send(value), let .receive(value):
                return value
            }
        }
    }
}
