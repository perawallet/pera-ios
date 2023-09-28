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
//   WCSessionShortListDataSource.swift

import UIKit

final class WCSessionShortListDataSource: NSObject {
    weak var delegate: WCSessionShortListDataSourceDelegate?

    private let walletConnectCoordinator: WalletConnectCoordinator

    private var sessions: [WCSessionDraft]

    init(walletConnectCoordinator: WalletConnectCoordinator) {
        self.walletConnectCoordinator = walletConnectCoordinator
        let sessions = walletConnectCoordinator.getSessions()
        let wcV2SessionConnectionDates =
            walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV2Protocol.getConnectionDates()
        let sortedSessionsByDescendingConnectionDate = sessions.sorted { firstSession, secondSession in
            let firstConnectionDate =
                firstSession.wcV1Session?.date ??
                wcV2SessionConnectionDates[firstSession.wcV2Session!.topic]
            let secondConnectionDate =
                secondSession.wcV1Session?.date ??
                wcV2SessionConnectionDates[secondSession.wcV2Session!.topic]

            guard let firstConnectionDate = firstConnectionDate,
                  let secondConnectionDate = secondConnectionDate else {
                return false
            }

            return firstConnectionDate > secondConnectionDate
        }
        self.sessions = sortedSessionsByDescendingConnectionDate
        super.init()
    }
}

extension WCSessionShortListDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(WCSessionShortListItemCell.self, at: indexPath)

        if let session = sessions[safe: indexPath.item] {
            let viewModel = WCSessionShortListItemViewModel(session)
            cell.bindData(viewModel)
        }

        cell.delegate = self
        return cell
    }
}

extension WCSessionShortListDataSource {
    func session(at index: Int) -> WCSessionDraft? {
        return sessions[safe: index]
    }

    func disconnectFromSession(_ session: WCSessionDraft) {
        if let wcV1Session = session.wcV1Session {
            let params = WalletConnectV1SessionDisconnectionParams(session: wcV1Session)
            walletConnectCoordinator.disconnectFromSession(params)
            return
        }

        if let wcV2Session = session.wcV2Session {
            let params = WalletConnectV2SessionDisconnectionParams(session: wcV2Session)
            walletConnectCoordinator.disconnectFromSession(params)
            return
        }
    }

    func updateSessions(_ updatedSessions: [WCSessionDraft]) {
        sessions = updatedSessions
    }
}

extension WCSessionShortListDataSource: WCSessionShortListItemCellDelegate {
    func wcSessionShortListItemCellDidOpenDisconnectionMenu(_ wcSessionShortListItemCell: WCSessionShortListItemCell) {
        delegate?.wcSessionShortListDataSource(self, didOpenDisconnectMenuFrom: wcSessionShortListItemCell)
    }
}

protocol WCSessionShortListDataSourceDelegate: AnyObject {
    func wcSessionShortListDataSource(_ wcSessionShortListDataSource: WCSessionShortListDataSource, didOpenDisconnectMenuFrom cell: WCSessionShortListItemCell)
}
