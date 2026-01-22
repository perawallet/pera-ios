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

//   AssetInnerTransactionPreviewViewModel.swift

import Foundation
import MacaroonUIKit
import pera_wallet_core

struct AssetInnerTransactionPreviewViewModel:
    InnerTransactionPreviewViewModel {
    var title: EditText?
    var amountViewModel: TransactionAmountViewModel?

    init(
        transaction: TransactionItem,
        account: Account,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle(transaction)
        bindAmount(
            transaction: transaction,
            account: account,
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }
}

extension AssetInnerTransactionPreviewViewModel {
    private mutating func bindTitle(
        _ transaction: TransactionItem
    ) {
        title = Self.getTitle(
            transaction.sender.shortAddressDisplay
        )
    }

    private mutating func bindAmount(
        transaction: TransactionItem,
        account: Account,
        asset: Asset?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let asset = asset else { return }
        
        let receiverAddress: String? = {
            if let tx = transaction as? Transaction, let assetTransfer = tx.assetTransfer { return assetTransfer.receiverAddress }
            if let tx = transaction as? TransactionV2 { return tx.receiver }
            return nil
        }()
        
        let amount: Decimal? = {
            if let tx = transaction as? Transaction, let assetTransfer = tx.assetTransfer { return assetTransfer.amount.assetAmount(fromFraction: asset.decimals) }
            if let tx = transaction as? TransactionV2 { return tx.assetTransferTransactionDetail?.amountValue ?? tx.amountValue }
            return nil
        }()
        
        guard let amount else { return }

        if receiverAddress == transaction.sender {
            amountViewModel = TransactionAmountViewModel(
                .normal(
                    amount: amount,
                    isAlgos: false,
                    fraction: asset.decimals,
                    assetSymbol: getAssetSymbol(
                        from: asset
                    )
                ),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if receiverAddress == account.address {
            amountViewModel = TransactionAmountViewModel(
                .positive(
                    amount: amount,
                    isAlgos: false,
                    fraction: asset.decimals,
                    assetSymbol: getAssetSymbol(
                        from: asset
                    )
                ),
                currency: currency,
                currencyFormatter: currencyFormatter,
                showAbbreviation: true
            )
            return
        }

        if transaction.sender == account.address {
            amountViewModel = TransactionAmountViewModel(
                .negative(
                    amount: amount,
                    isAlgos: false,
                    fraction: asset.decimals,
                    assetSymbol: getAssetSymbol(
                        from: asset
                    )
                ),
                currency: currency,
                currencyFormatter: currencyFormatter
            )
            return
        }

        amountViewModel = TransactionAmountViewModel(
            .normal(
                amount: amount,
                isAlgos: false,
                fraction: asset.decimals,
                assetSymbol: getAssetSymbol(
                    from: asset
                )
            ),
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }
}
