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

//   AssetTransactionItemViewModel.swift

import Foundation
import MacaroonUIKit
import pera_wallet_core

struct AssetTransactionItemViewModel:
    TransactionListItemViewModel,
    Hashable {
    let isValueHidden: Bool
    var id: String?
    var title: EditText?
    var subtitle: EditText?
    var icon: Image?
    var transactionAmountViewModel: TransactionAmountViewModel?

    init(
        _ draft: TransactionViewModelDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter,
        isValueHidden: Bool
    ) {
        self.isValueHidden = isValueHidden
        bindID(draft)
        bindTitle(draft)
        bindSubtitle(draft)
        bindIcon(draft)
        bindAmount(
            draft,
            currency: currency,
            currencyFormatter: currencyFormatter
        )
    }

    private mutating func bindID(
        _ draft: TransactionViewModelDraft
    ) {
        id = draft.transaction.id
    }

    private mutating func bindTitle(
        _ draft: TransactionViewModelDraft
    ) {
        
        let amount: UInt64? = {
            if let tx = draft.transaction as? Transaction { return tx.getCloseAmount() }
            if let tx = draft.transaction as? TransactionV2, let amt = tx.amount { return UInt64(amt) }
            return nil
        }()

        let closeToAddress: String? = {
            if let tx = draft.transaction as? Transaction { return tx.getCloseAddress() }
            if let tx = draft.transaction as? TransactionV2 { return tx.closeTo }
            return nil
        }()

        let receiver: String? = {
            if let tx = draft.transaction as? Transaction, let assetTransfer = tx.assetTransfer { return assetTransfer.receiverAddress }
            if let tx = draft.transaction as? TransactionV2 { return tx.receiver }
            return nil
        }()
        
        
        if let closeAddress = closeToAddress {
            let titleKey: String.LocalizationValue = closeAddress == draft.account.address
                ? "transaction-item-receive-opt-out"
                : "title-opt-out"
            bindTitle(String(localized: titleKey))
            return
        }

        if draft.transaction.sender == draft.account.address && draft.transaction.isSelfTransaction {
            let titleKey: String.LocalizationValue = (amount ?? 0) != 0
                ? "transaction-item-self-transfer"
                : "transaction-item-opt-in"
            bindTitle(String(localized: titleKey))
            return
        }

        let titleKey: String.LocalizationValue = (draft.account.address == receiver)
            ? "transaction-detail-receive"
            : "transaction-detail-send"

        bindTitle(String(localized: titleKey))
    }

    private mutating func bindSubtitle(
        _ draft: TransactionViewModelDraft
    ) {

        let closeToAddress: String? = {
            if let tx = draft.transaction as? Transaction { return tx.getCloseAddress() }
            if let tx = draft.transaction as? TransactionV2 { return tx.closeTo }
            return nil
        }()

        let receiver: String? = {
            if let tx = draft.transaction as? Transaction, let assetTransfer = tx.assetTransfer { return assetTransfer.receiverAddress }
            if let tx = draft.transaction as? TransactionV2 { return tx.receiver }
            return nil
        }()
        
        guard let receiver else { return }

        if draft.transaction.isSelfTransaction {
            subtitle = nil
            return
        }

        let targetAddress: String
        if let close = closeToAddress {
            targetAddress = close
        } else if isReceivingTransaction(draft, for: receiver), let sender = draft.transaction.sender {
            targetAddress = sender
        } else {
            targetAddress = receiver
        }

        bindSubtitle(getSubtitle(from: draft, for: targetAddress))
    }
    
    private mutating func bindIcon(
        _ draft: TransactionViewModelDraft
    ) {
        guard let tx = draft.transaction as? TransactionV2 else { return }
        
        if tx.closeTo != nil {
            bindIcon("icon-transaction-list-optin")
            return
        }

        if draft.transaction.sender == draft.account.address && draft.transaction.isSelfTransaction {
            bindIcon("icon-transaction-list-optin")
            return
        }

        if draft.account.address == tx.receiver {
            bindIcon("icon-transaction-list-receive")
        } else {
            bindIcon("icon-transaction-list-send")
        }
    }

    private mutating func bindAmount(
        _ draft: TransactionViewModelDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        
        let receiver: String? = {
            if let tx = draft.transaction as? Transaction, let assetTransfer = tx.assetTransfer { return assetTransfer.receiverAddress }
            if let tx = draft.transaction as? TransactionV2 { return tx.receiver }
            return nil
        }()
        
        let assetId: Int64? = {
            if let tx = draft.transaction as? Transaction, let assetTransfer = tx.assetTransfer { return assetTransfer.assetId }
            if let tx = draft.transaction as? TransactionV2, let asset = tx.asset, let assetIdString = asset.assetId, let assetId = Int64(assetIdString) { return assetId }
            return nil
        }()
        
        guard let receiver, let assetId, let asset = draft.localAssets?[assetId] else { return }
        
        let amount: Decimal? = {
            if let tx = draft.transaction as? Transaction, let assetTransfer = tx.assetTransfer {
                return assetTransfer.amount.assetAmount(fromFraction: asset.decimals)
            }
            
            if let tx = draft.transaction as? TransactionV2, let amount = tx.amount {
                return Decimal(string: amount)
            }
            
            return nil
        }()
        
        guard let amount else { return }
        
        currencyFormatter.isValueHidden = isValueHidden

        let style: TransactionAmountView.Mode
        if receiver == draft.transaction.sender || isValueHidden {
            style = .normal(amount: amount, isAlgos: false, fraction: asset.decimals, assetSymbol: getAssetSymbol(from: asset))
        } else if receiver == draft.account.address {
            style = .positive(amount: amount, isAlgos: false, fraction: asset.decimals, assetSymbol: getAssetSymbol(from: asset), hideSign: draft.transaction is TransactionV2)
        } else {
            style = .negative(amount: amount, isAlgos: false, fraction: asset.decimals, assetSymbol: getAssetSymbol(from: asset))
        }

        transactionAmountViewModel = TransactionAmountViewModel(
            style,
            currency: currency,
            currencyFormatter: currencyFormatter,
            showAbbreviation: true
        )
    }

    private func isReceivingTransaction(
        _ draft: TransactionViewModelDraft,
        for receiver: String
    ) -> Bool {
        return draft.account.address == receiver
    }
}
