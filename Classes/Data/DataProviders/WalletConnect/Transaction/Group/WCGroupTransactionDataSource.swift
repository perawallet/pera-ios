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
//   WCGroupTransactionDataSource.swift

import UIKit

class WCGroupTransactionDataSource: NSObject {

    weak var delegate: WCGroupTransactionDataSourceDelegate?

    private let transactions: [WCTransaction]
    private let walletConnector: WalletConnector

    init(transactions: [WCTransaction], walletConnector: WalletConnector) {
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WCGroupTransactionItemCell.reusableIdentifier,
            for: indexPath
        ) as? WCGroupTransactionItemCell else {
            fatalError("Unexpected cell type")
        }

        if let transaction = transaction(at: indexPath.item) {
            cell.bind(WCGroupTransactionItemViewModel(transaction: transaction))
        }

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

        // Will be updated with the related session later.
        if let session = walletConnector.allWalletConnectSessions.first,
           let transaction = transactions.first {
            headerView.bind(
                WCGroupTransactionHeaderViewModel(
                    session: session,
                    transaction: transaction,
                    transactionCount: transactions.count
                )
            )
        }

        headerView.delegate = self
        return headerView
    }
}

extension WCGroupTransactionDataSource {
    func transaction(at index: Int) -> WCTransaction? {
        return transactions[safe: index]
    }
}

extension WCGroupTransactionDataSource: WCGroupTransactionSupplementaryHeaderViewDelegate {
    func wcGroupTransactionSupplementaryHeaderViewDidOpenLongMessageView(
        _ wcGroupTransactionSupplementaryHeaderView: WCGroupTransactionSupplementaryHeaderView
    ) {
        delegate?.wcGroupTransactionDataSourceDidOpenLongDappMessageView(self)
    }
}

protocol WCGroupTransactionDataSourceDelegate: AnyObject {
    func wcGroupTransactionDataSourceDidOpenLongDappMessageView(_ wcGroupTransactionDataSource: WCGroupTransactionDataSource)
}
