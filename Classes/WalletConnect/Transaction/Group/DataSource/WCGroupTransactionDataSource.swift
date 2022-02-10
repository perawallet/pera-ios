// Copyright 2022 Pera Wallet, LDA

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
//   WCGroupTransactionDataSource.swift

import UIKit
import MacaroonUtils

class WCGroupTransactionDataSource: NSObject {

    private let sharedDataController: SharedDataController
    private let transactions: [WCTransaction]
    private let walletConnector: WalletConnector

    init(
        sharedDataController: SharedDataController,
        transactions: [WCTransaction],
        walletConnector: WalletConnector
    ) {
        self.sharedDataController = sharedDataController
        self.transactions = transactions
        self.walletConnector = walletConnector
        super.init()
    }
}

extension WCGroupTransactionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let transaction = transaction(at: indexPath.item) else {
            fatalError("Unexpected transaction")
        }

        let account: Account? = transaction.signerAccount

        if transaction.transactionDetail?.isAssetConfigTransaction ?? false {
            if transaction.signerAccount == nil {
                return dequeueUnsignableAssetConfigCell(in: collectionView, at: indexPath, for: transaction, with: account)
            }

            return dequeueAssetConfigCell(in: collectionView, at: indexPath, for: transaction, with: account)
        }

        if transaction.signerAccount == nil {
            return dequeueUnsignableCell(in: collectionView, at: indexPath, for: transaction)
        }

        return dequeueSingleSignerCell(in: collectionView, at: indexPath, for: transaction, with: account)
    }

    private func dequeueUnsignableAssetConfigCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction,
        with account: Account?
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCAssetConfigAnotherAccountTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCAssetConfigAnotherAccountTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(
            WCAssetConfigTransactionItemViewModel(
                transaction: transaction,
                account: account,
                assetInformation: assetInformation(from: transaction)
            )
        )

        return cell
    }

    private func dequeueAssetConfigCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction,
        with account: Account?
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCAssetConfigTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCAssetConfigTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(
            WCAssetConfigTransactionItemViewModel(
                transaction: transaction,
                account: account,
                assetInformation: assetInformation(from: transaction)
            )
        )

        return cell
    }

    private func dequeueUnsignableCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCGroupAnotherAccountTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCGroupAnotherAccountTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(
            WCGroupTransactionItemViewModel(
                transaction: transaction,
                account: nil,
                assetInformation: assetInformation(from: transaction),
                currency: sharedDataController.currency.value
            )
        )

        return cell
    }

    private func dequeueSingleSignerCell(
        in collectionView: UICollectionView,
        at indexPath: IndexPath,
        for transaction: WCTransaction,
        with account: Account?
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCGroupTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCGroupTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        cell.bind(
            WCGroupTransactionItemViewModel(
                transaction: transaction,
                account: account,
                assetInformation: assetInformation(from: transaction),
                currency: sharedDataController.currency.value
            )
        )

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            fatalError("Unexpected element kind")
        }

        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: WCGroupTransactionSupplementaryHeaderView.reusableIdentifier,
            for: indexPath
        ) as? WCGroupTransactionSupplementaryHeaderView else {
            fatalError("Unexpected element kind")
        }

        headerView.bind(WCGroupTransactionHeaderViewModel(transactions: transactions))
        return headerView
    }
}

extension WCGroupTransactionDataSource {
    func transaction(at index: Int) -> WCTransaction? {
        return transactions[safe: index]
    }

    private func assetInformation(from transaction: WCTransaction) -> AssetInformation? {
        guard let assetId = transaction.transactionDetail?.currentAssetId else {
            return nil
        }

        return sharedDataController.assetDetailCollection[assetId]
    }
}
