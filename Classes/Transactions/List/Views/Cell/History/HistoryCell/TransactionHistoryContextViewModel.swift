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

final class TransactionHistoryContextViewModel: ViewModel {
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

        let account = transactionDependencies.account
        let contact = transactionDependencies.contact

        if let assetDetail = transactionDependencies.assetDetail {
            guard let assetTransaction = transaction.assetTransfer else {
                return
            }

            if assetTransaction.receiverAddress == assetTransaction.senderAddress {
                bindTitleAndSubtitle(with: contact, and: .receiver(assetTransaction.receiverAddress))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .normal(
                        amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                        isAlgos: false,
                        fraction: assetDetail.fractionDecimals
                    )
                )
            } else if assetTransaction.receiverAddress == account.address &&
                assetTransaction.amount == 0 &&
                transaction.type == .assetTransfer {
                title = "asset-creation-fee-title".localized
                if let fee = transaction.fee {
                    transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: fee.toAlgos))
                }
            } else if assetTransaction.receiverAddress == account.address {
                bindTitleAndSubtitle(with: contact, and: .receiver(assetTransaction.receiverAddress))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .positive(
                        amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                        isAlgos: false,
                        fraction: assetDetail.fractionDecimals
                    )
                )
            } else {
                bindTitleAndSubtitle(with: contact, and: .receiver(assetTransaction.receiverAddress))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .negative(
                        amount: assetTransaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                        isAlgos: false,
                        fraction: assetDetail.fractionDecimals
                    )
                )
            }
        } else {
            guard let payment = transaction.payment else {
                if let assetTransaction = transaction.assetTransfer,
                    assetTransaction.receiverAddress == account.address
                    && assetTransaction.amount == 0
                    && transaction.type == .assetTransfer {
                    title = "asset-creation-fee-title".localized
                    if let fee = transaction.fee {
                        transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: fee.toAlgos))
                    }
                }
                return
            }

            if payment.receiver == transaction.sender {
                bindTitleAndSubtitle(with: contact, and: .sender(transaction.sender))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .normal(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
                )
            } else if payment.receiver == account.address {
                bindTitleAndSubtitle(with: contact, and: .sender(transaction.sender))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .positive(amount: payment.amountForTransaction(includesCloseAmount: true).toAlgos)
                )
            } else {
                bindTitleAndSubtitle(with: contact, and: .receiver(payment.receiver))
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
                bindTitleAndSubtitle(with: contact, and: .receiver(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .normal(
                        amount: transaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                        isAlgos: false,
                        fraction: assetDetail.fractionDecimals
                    )
                )
            } else if transaction.receiver == account.address && transaction.amount == 0 && transaction.type == .assetTransfer {
                title = "asset-creation-fee-title".localized
                if let fee = transaction.fee {
                    transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: fee.toAlgos))
                }
            } else if transaction.receiver == account.address {
                bindTitleAndSubtitle(with: contact, and: .receiver(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .positive(
                        amount: transaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                        isAlgos: false,
                        fraction: assetDetail.fractionDecimals
                    )
                )
            } else {
                bindTitleAndSubtitle(with: contact, and: .receiver(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(
                    .negative(
                        amount: transaction.amount.assetAmount(fromFraction: assetDetail.fractionDecimals),
                        isAlgos: false,
                        fraction: assetDetail.fractionDecimals
                    )
                )
            }
        } else {
            if transaction.receiver == transaction.sender {
                bindTitleAndSubtitle(with: contact, and: .receiver(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(.normal(amount: transaction.amount.toAlgos))
            } else if transaction.receiver == account.address {
                bindTitleAndSubtitle(with: contact, and: .sender(transaction.sender))
                transactionAmountViewModel = TransactionAmountViewModel(.positive(amount: transaction.amount.toAlgos))
            } else {
                bindTitleAndSubtitle(with: contact, and: .receiver(transaction.receiver))
                transactionAmountViewModel = TransactionAmountViewModel(.negative(amount: transaction.amount.toAlgos))
            }
        }
    }
}

extension TransactionHistoryContextViewModel {
    private func bindTitleAndSubtitle(with contact: Contact?, and address: Address?) {
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
        case sender(String?)
        case receiver(String?)

        var title: String {
            switch self {
            case .sender:
                return "Sender"
            case .receiver:
                return "Receiver"
            }
        }

        var associatedValue: String? {
            switch self {
            case let .sender(value), let .receiver(value):
                return value
            }
        }
    }
}
