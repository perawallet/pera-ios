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
//   WCMainTransactionDataSource.swift

import UIKit

class WCMainTransactionDataSource: NSObject {

    weak var delegate: WCMainTransactionDataSourceDelegate?

    private let transactions: [WCTransaction]
    private let walletConnector: WalletConnector

    init(transactions: [WCTransaction], walletConnector: WalletConnector) {
        self.transactions = transactions
        self.walletConnector = walletConnector
        super.init()
    }
}

extension WCMainTransactionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
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
            withReuseIdentifier: WCMainTransactionSupplementaryHeaderView.reusableIdentifier,
            for: indexPath
        ) as? WCMainTransactionSupplementaryHeaderView else {
            fatalError("Unexpected element kind")
        }

        // Will be updated with the related session later.
        if let session = walletConnector.allWalletConnectSessions.first,
           let transaction = transactions.first {
            headerView.bind(
                WCMainTransactionHeaderViewModel(
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

extension WCMainTransactionDataSource {
    func transaction(at index: Int) -> WCTransaction? {
        return transactions[safe: index]
    }
}

extension WCMainTransactionDataSource: WCMainTransactionSupplementaryHeaderViewDelegate {
    func wcMainTransactionSupplementaryHeaderViewDidOpenLongMessageView(
        _ wcMainTransactionSupplementaryHeaderView: WCMainTransactionSupplementaryHeaderView
    ) {
        delegate?.wcMainTransactionDataSourceDidOpenLongDappMessageView(self)
    }
}

protocol WCMainTransactionDataSourceDelegate: AnyObject {
    func wcMainTransactionDataSourceDidOpenLongDappMessageView(_ wcMainTransactionDataSource: WCMainTransactionDataSource)
}
