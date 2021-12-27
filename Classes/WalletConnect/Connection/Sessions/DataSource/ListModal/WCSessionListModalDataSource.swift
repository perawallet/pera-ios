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
//   WCSessionListModalDataSource.swift

import UIKit

final class WCSessionListModalDataSource: NSObject {
    weak var delegate: WCSessionListModalDataSourceDelegate?

    private let walletConnector: WalletConnector

    private var sessions: [WCSession]

    init(walletConnector: WalletConnector) {
        self.walletConnector = walletConnector
        self.sessions = walletConnector.allWalletConnectSessions
        super.init()
    }
}

extension WCSessionListModalDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(WCSessionListModalItemCell.self, at: indexPath)

        if let session = sessions[safe: indexPath.item] {
            cell.bindData(WCSessionsListModalItemViewModel(session))
        }

        cell.delegate = self
        return cell
    }
}

extension WCSessionListModalDataSource {
    func session(at index: Int) -> WCSession? {
        return sessions[safe: index]
    }

    func disconnectFromSession(_ session: WCSession) {
        walletConnector.disconnectFromSession(session)
    }

    func updateSessions(_ updatedSessions: [WCSession]) {
        sessions = updatedSessions
    }
}

extension WCSessionListModalDataSource: WCSessionListModalItemCellDelegate {
    func wcSessionListModalItemCellDidOpenDisconnectionMenu(_ wcSessionListModalItemCell: WCSessionListModalItemCell) {
        delegate?.wcSessionListModalDataSource(self, didOpenDisconnectMenuFrom: wcSessionListModalItemCell)
    }
}

protocol WCSessionListModalDataSourceDelegate: AnyObject {
    func wcSessionListModalDataSource(_ wcSessionListModalDataSource: WCSessionListModalDataSource, didOpenDisconnectMenuFrom cell: WCSessionListModalItemCell)
}
